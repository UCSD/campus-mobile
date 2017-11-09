import React from 'react';
import {
	View,
	Text,
	ScrollView,
	Image,
	ListView,
} from 'react-native';
import moment from 'moment';
import { connect } from 'react-redux';
import css from '../../styles/css';
import logger from '../../util/logger';

var surfHeader = require('../../assets/img/surf_report_header.jpg');
var surfDataSource = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});

class SurfReport extends React.Component {
	componentDidMount() {
		logger.ga('Card Mounted: Surf Report2');
	}

	render() {
		return (
			<ScrollView style={css.main_full}>
				<Image style={css.sr_headerImage} source={surfHeader} />

				<View style={css.dateDayContainer}>
					<View style={css.dateDayHeader}>
						<Text style={css.dateDayOfWeek}>{this.props.surfData.lastUpdated}</Text>
						<Text style={css.dateDayAndMonth}>{this.props.surfData.forecast}</Text>
					</View>
				</View>

				<ListView
					dataSource={surfDataSource.cloneWithRows(this.props.surfData.spots)}
					renderRow={rowData => this.surfItem(rowData)}
				/>
			</ScrollView>
		);
	}

	surfItem(rowData) {
		return (
			<View style={css.sr_surfDetailsContainer}>
				<View style={css.sr_surfDetailsEmpty} />
				<View style={css.sr_surfDetails}>
					<Text style={css.sr_titleText}>{rowData.title}</Text>
					<Text style={css.sr_heightText}>tbd</Text>
				</View>
			</View>
		);
	}
}


function mapStateToProps(state) {
	return {
		surfData: state.surf.data,
	};
}

const ActualSurfReport = connect(
	mapStateToProps
)(SurfReport);

export default ActualSurfReport;
