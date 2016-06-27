'use strict';

import React from 'react';
import {
    Platform,
	View,
	Text,
	TouchableOpacity,
	ScrollView,
	Image,
	ListView,
	Date,
} from 'react-native';

var dateFormat = require('dateformat');

var css = require('../styles/css');
var logger = require('../util/logger');
var general = require('../util/general');
var surf_report_header = require('../assets/img/surf_report_header.jpg');

var SurfReport = React.createClass({

	getInitialState: function() {
		return {
			surfData: null,
		}
	},

	componentWillMount: function() {

		logger.custom('View Loaded: Surf Report');

		var dsFull = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});

		if (this.props.route.surfData) {

			this.surfDataArray = [];

			for (var i = 0; this.props.route.surfData.length > i; i++) {

				var surfDataRow = this.props.route.surfData[i];

				var surfDataRowObj = {};

				surfDataRowObj.surfTitle = surfDataRow.title.replace(/ \: .*/g, '');
				surfDataRowObj.surfHeight = surfDataRow.title.replace(/.* \: /g, '').replace(/ft.*/g, '').replace(/^\./g, '').replace(/^ /g, '').replace(/ $/g, '').replace(/Surf\: /g, '') + ' ft';
				surfDataRowObj.surfDesc = surfDataRow.title.replace(/.*ft/g, '').replace(/^\./g, '').replace(/ \+ - /g, '').replace(/\+ - /g, '').replace(/^ /g, '').replace(/ $/g, '').replace(/^- /g, '');
				surfDataRowObj.surfDesc = this.capitalizeFirstLetter(surfDataRowObj.surfDesc);

				surfDataRowObj.surfDate = surfDataRow.date.replace(/ PDT/g, '');
				surfDataRowObj.surfTimestamp = dateFormat(surfDataRowObj.surfDate, 'isoDateTime');
				surfDataRowObj.surfTimestampNumeric = surfDataRowObj.surfTimestamp.substring(0,10).replace(/-/g, '');
				surfDataRowObj.surfDayOfWeek = dateFormat(surfDataRowObj.surfDate, 'ddd').toUpperCase();
				surfDataRowObj.surfDayOfMonth = dateFormat(surfDataRowObj.surfDate, 'd');
				surfDataRowObj.surfMonth = dateFormat(surfDataRowObj.surfDate, 'mmm');
				
				if (surfDataRowObj.surfTimestampNumeric === general.getTimestampNumeric()) {
					this.surfDataArray.push(surfDataRowObj);
				}
			}

			// Sort the result rows so we can break different days into groups
			this.surfDataArray.sort(this.compare);

			this.surfRowPreviousTimestamp = null;
			this.surfRowCurrentTimestamp = null;

			this.setState({
				surfData: dsFull.cloneWithRows(this.surfDataArray),
			});

		}
	},

	compare: function(a, b) {
		if (a.surfTimestampNumeric < b.surfTimestampNumeric) {
			return -1;
		} else if (a.surfTimestampNumeric > b.surfTimestampNumeric) {
			return 1;
		} else {
			return 0;
		}
	},

	render: function() {
		return this.renderScene();
	},

	renderScene: function() {
		return (
			<View style={[css.main_container, css.whitebg]}>
				<ScrollView contentContainerStyle={[css.scroll_main, css.whitebg]}>
					<Image style={css.sr_image} source={require('../assets/img/surf_report_header.jpg')} />
					
					{this.state.surfData ? (
						<ListView dataSource={this.state.surfData} renderRow={ this.renderSurfReportRow } style={css.wf_listview} />
					) : (
						<View style={css.flexcenter3}>
							<Image style={css.shuttlecard_loading} source={{ uri: "https://s3-us-west-2.amazonaws.com/ucsd-images/ajax-loader.gif" }} />
						</View>
					)}

				</ScrollView>
			</View>
		);
	},

	renderSurfReportRow: function(data) {

		this.surfRowCurrentTimestamp = data.surfTimestampNumeric;

		if (this.surfRowPreviousTimestamp === null) {
			this.surfRowPreviousTimestamp = data.surfTimestampNumeric;
			return (
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
		} else if (this.surfRowCurrentTimestamp === this.surfRowPreviousTimestamp) {
			this.surfRowPreviousTimestamp = data.surfTimestampNumeric;
			return (
				<View style={css.sr_day_row}>
					<View style={css.sr_day_date_container}></View>
					<View style={css.sr_day_details_container}>
						<View style={css.sr_day_details_container_inner}>
							<Text style={css.sr_day_details_title}>{data.surfTitle}</Text>
							<Text style={css.sr_day_details_height}>{data.surfHeight}</Text>
							{data.surfDesc ? (<Text style={css.sr_day_details_desc}>{data.surfDesc}</Text>) : null }
						</View>
					</View>
				</View>
			);
		} else {
			this.surfRowPreviousTimestamp = data.surfTimestampNumeric;
			return (
				<View style={[css.sr_day_row, css.sr_day_row_border]}>
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
		}
	},

	capitalizeFirstLetter: function(string) {
		return string.charAt(0).toUpperCase() + string.slice(1);
	},

});

module.exports = SurfReport;