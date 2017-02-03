import React from 'react';
import {
	View,
	Text,
	ScrollView,
	Image,
	ListView,
	AppState
} from 'react-native';

import { connect } from 'react-redux';
import { updateSurf } from '../../actions/surf';

const css = require('../../styles/css');
const AppSettings = require('../../AppSettings');
const logger = require('../../util/logger');

const surfDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });
const surfHeader = require('../../assets/img/surf_report_header.jpg');

class SurfReport extends React.Component {
	componentDidMount() {
		logger.log('View Mounted: Surf');

		this.props.updateSurf();

		AppState.addEventListener('change', this._handleAppStateChange);
	}

	componentWillUnmount() {
		AppState.removeEventListener('change', this._handleAppStateChange);
	}

	_handleAppStateChange = (currentAppState) => {
		this.setState({ currentAppState });

		// check TTL and refresh surf data if needed
		if (currentAppState === 'active') {
			const nowTime = new Date.getTime();
			const timeDiff = nowTime - this.props.surfLastUpdated;
			const surfTTL = AppSettings.SURF_API_TTL * 1000; // convert secs to ms

			if (timeDiff > surfTTL) {
				this.props.updateSurf();
			}
		}
	}

	render() {
		return (<SurfView
			surfData={this.props.surfData}
		/>);
	}
}

// This stuff should be moved to different files, but we should be redoing this view soon
const SurfView = ({ surfData }) => (
	<View style={[css.main_container, css.whitebg]}>
		<ScrollView contentContainerStyle={[css.scroll_main, css.whitebg]}>
			<Image
				style={css.sr_image}
				source={surfHeader}
			/>
			{surfData ? (
				<SurfList
					surfData={surfDataSource.cloneWithRows(surfData)}
				/>
			) : null }
			{!surfData ? (
				<Text style={[css.center, css.pad40]}>There is no surf data available at this time.{'\n'}Please check back later.</Text>
			) : null }
		</ScrollView>
	</View>
);

const SurfList = ({ surfData }) => (
	<ListView
		dataSource={surfData}
		style={css.wf_listview}
		renderRow={
			(row, sectionID, rowID) =>
				<SurfItem
					data={row}
				/>
		}
	/>
);

const SurfItem = ({ data }) => (
	<View style={css.sr_day_row}>
		<View style={css.sr_day_date_container}>
			<Text style={css.sr_dayofweek}>{data.surfDayOfWeek}</Text>
			<Text style={css.sr_dayandmonth}>{data.surfDayOfMonth} {data.surfMonth}</Text>
		</View>

		<View style={css.sr_day_details_container}>
			<View style={css.sr_day_details_container_inner}>
				<Text style={css.sr_day_details_title}>{data.surfTitle}</Text>
				<Text style={css.sr_day_details_height}>{data.surfHeight}</Text>
				{data.surfDesc ? (<Text style={css.sr_day_details_desc}>{data.surfDesc}</Text>) : null }
			</View>
		</View>
	</View>
);

const mapStateToProps = (state) => (
	{
		surfData: state.surf.data,
		surfLastUpdated: state.surf.lastUpdated,
	}
);

const mapDispatchToProps = (dispatch) => (
	{
		updateSurf: () => {
			dispatch(updateSurf());
		}
	}
);

const ActualSurfReport = connect(
	mapStateToProps,
	mapDispatchToProps
)(SurfReport);

export default ActualSurfReport;
