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
var mapWeekdays = [
	'Sunday',
	'Monday',
	'Tuesday',
	'Wednesday',
	'Thursday',
	'Friday',
	'Saturday'
]
var mapMonths = [
	'January',
	'February',
	'March',
	'April',
	'May',
	'June',
	'July',
	'August',
	'September',
	'October',
	'November',
	'December'
]

class SurfReport extends React.Component {
	componentDidMount() {
		logger.ga('Card Mounted: Surf Report2');
	}

	render() {
		var dateString = new Date(this.props.surfData.spots[0].date)
		
		if ("forecast" in this.props.surfData && this.props.surfData.forecast.length !== 0) {
			this.formatForecast(this.props.surfData.forecast);
		}
		return (
			<ScrollView style={css.main_full}>
				<Image style={css.sr_headerImage} source={surfHeader} />

				<View style={css.dateDayContainer}>
					<View style={css.dateDayHeader}>
						<Text style={css.sr_reportTitle}>
							{mapWeekdays[dateString.getDay()]}
							{', '}
							{mapMonths[dateString.getMonth()]} 
							{' '}
							{dateString.getDate()}
						</Text> 
						{forecastParsed}
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
				<View key={forecast.indexOf(rep)} style={css.dateDayHeader}> 
					<Text style={css.sr_reportTitle}>{rep}</Text>
				</View>
			) : forecastParsed.push(
				<View key={forecast.indexOf(rep)} style={css.dateDayHeader}> 
					<Text style={css.sr_reportText}>{rep}</Text>
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
