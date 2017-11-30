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
var forecastParsed = [];

class SurfReport extends React.Component {
	componentDidMount() {
		logger.ga('Card Mounted: Surf Report2');
	}

	render() {
		
		if ("forecast" in this.props.surfData && this.props.surfData.forecast.length !== 0) {
			this.formatForecast(this.props.surfData.forecast);
		}
		return (
			<ScrollView style={css.main_full}>
				<Image style={css.sr_headerImage} source={surfHeader} />

				<View style={css.dateDayContainer}>
					<View style={css.dateDayHeader}> 
						{forecastParsed}
					</View>
				</View>

				<ListView
					dataSource={surfDataSource.cloneWithRows(this.props.surfData.spots)}
					renderRow={rowData => this.surfItem(rowData)}
					renderSectionHeader={(sectionData) => {
						var dateString = new Date(sectionData[0]['date']).toDateString();
						return (
							<View style={css.sr_dateDayContainer}>
								<View style={css.sr_dateDayHeader}>
									<Text style={css.sr_dateDayOfWeek}>{dateString.substring(4,10)}</Text>
									<Text style={css.sr_dateDayAndMonth}>{dateString.substring(0,3)}</Text>
								</View>
								<View style={css.sr_dateDayEmpty} />
							</View>
						);
					}}
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
					<Text style={css.sr_heightText}>{rowData.surf_min}{'-'}{rowData.surf_max}{'ft'}</Text>
				</View>
			</View>
		);
	}

	formatForecast(forecast) {
		forecastParsed = [];
		var reports = forecast.map(function(rep){
			forecast.indexOf(rep)%2==0 ? forecastParsed.push(
				<View style={css.dateDayHeader}> 
					<Text style={css.sr_reportTitle}>{rep.replace(/&nbsp;/g,'')}</Text>
				</View>
			) : forecastParsed.push(
				<View style={css.dateDayHeader}> 
					<Text style={css.sr_reportText}>{rep.replace(/&nbsp;/g,'')}</Text>
				</View>);
		})}
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
