import React from 'react';
import {
	View,
	Text,
	ScrollView,
	Image,
	ListView,
	ActivityIndicator,
} from 'react-native';

import NavigationBarWithRouteMapper from '../NavigationBarWithRouteMapper';

const dateFormat = require('dateformat');

const css = require('../../styles/css');
const AppSettings = require('../../AppSettings');
const logger = require('../../util/logger');
const general = require('../../util/general');

const SurfReport = React.createClass({

	getInitialState() {
		return {
			surfData: null,
			surfDataNoResults: null,
		};
	},

	componentWillMount() {
		logger.ga('View Loaded: Surf Report');

		const dsFull = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

		if (this.props.route.surfData) {
			this.surfDataArray = [];

			for (let i = 0; this.props.route.surfData.length > i; i++) {
				const surfDataRow = this.props.route.surfData[i];

				const surfDataRowObj = {};

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

			// If no results for today, set surfDataNoResults true, and display a message
			if (this.surfDataArray.length === 0) {
				this.setState({ surfDataNoResults: true });
			} else {
				// Sort the result rows so we can break different days into groups
				this.surfDataArray.sort(this.compare);
				this.surfRowPreviousTimestamp = null;
				this.surfRowCurrentTimestamp = null;
				this.setState({ surfData: dsFull.cloneWithRows(this.surfDataArray) });
			}
		}
	},

	compare(a, b) {
		if (a.surfTimestampNumeric < b.surfTimestampNumeric) {
			return -1;
		} else if (a.surfTimestampNumeric > b.surfTimestampNumeric) {
			return 1;
		} else {
			return 0;
		}
	},

	render() {
		if (general.platformAndroid()) {
			return (
				<NavigationBarWithRouteMapper
					route={this.props.route}
					renderScene={this.renderScene}
					navigator={this.props.navigator}
				/>
			);
		} else {
			return this.renderScene();
		}
	},

	renderScene() {
		return (
			<View style={[css.main_container, css.whitebg]}>
				<ScrollView contentContainerStyle={[css.scroll_main, css.whitebg]}>
					<Image style={css.sr_image} source={require('../../assets/img/surf_report_header.jpg')} />
					{this.state.surfData ? (
						<ListView dataSource={this.state.surfData} renderRow={this.renderSurfReportRow} style={css.wf_listview} />
					) : null }
					{!this.state.surfData && !this.state.surfDataNoResults ? (
						<ActivityIndicator style={[css.center, css.mar40]} size="large" />
					) : null }
					{this.state.surfDataNoResults ? (
						<Text style={[css.center, css.pad40]}>There is no surf data available at this time.{'\n'}Please check back later.</Text>
					) : null }
				</ScrollView>
			</View>
		);
	},

	renderSurfReportRow(data) {
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
					<View style={css.sr_day_date_container} />
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

	capitalizeFirstLetter(string) {
		return string.charAt(0).toUpperCase() + string.slice(1);
	},

});

module.exports = SurfReport;
