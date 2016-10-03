'use strict';

import React from 'react'
import {
	View,
	ListView,
	Text,
	TouchableHighlight,
	ActivityIndicator,
	InteractionManager,
	Image,
} from 'react-native';

var css = require('../../styles/css');
var logger = require('../../util/logger');
var general = require('../../util/general');

var DiningDetail = require('./DiningDetail');

var DiningList = React.createClass({

	getInitialState: function() {

		logger.log('t3--------------')
		return {
			loaded: false
		};
	},

	componentDidMount() {
		logger.ga('View Loaded: Dining: View All Locations2');

		InteractionManager.runAfterInteractions(() => {
			this.setState({loaded: true})
		});
	},

	render: function() {
		if (!this.state.loaded) {
			return this.renderLoadingView();
		}
		return this.renderListView();
	},

	renderLoadingView: function() {
		return (
			<View style={css.main_container}>
				<ActivityIndicator
					animating={this.state.animating}
					style={css.welcome_ai}
					size="large"
				/>
			</View>
		);
	},

	renderListView: function() {
		var diningData = this.props.route.data;

		logger.log('diningData3')
		logger.log(diningData)
		var datasource = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
		var diningDatasource = datasource.cloneWithRows(diningData);
		return (
			<View style={[css.main_container, css.view_default]}>
				<ListView dataSource={diningDatasource} renderRow={this.renderDiningRow} />
			</View>
		);
	},

	renderDiningRow: function(data) {
		var currentTimestamp = general.getTimestamp('yyyy-mm-dd');
		var dayOfWeek = general.getTimestamp('ddd').toLowerCase();

		return (
			<View style={css.dc_locations_row}>
				<TouchableHighlight style={css.dc_locations_row_left} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoDiningDetail(data) }>
					<View>
						<Text style={css.dc_locations_title}>{data.name}</Text>
						<Text style={css.dc_locations_hours}>{data.regularHours}</Text>
					</View>
				</TouchableHighlight>
				{data.coords.lat != 0 ? (
					<TouchableHighlight style={css.dc_locations_row_right} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => general.gotoNavigationApp('walk', data.coords.lat, data.coords.lon) }>
						<View style={css.dl_dir_traveltype_container}>
							<Image style={css.dl_dir_icon} source={ require('../../assets/img/icon_walk.png')} />
							<Text style={css.dl_dir_eta}>Walk</Text>
						</View>
					</TouchableHighlight>
				) : null }
			</View>
		);
	},

	gotoDiningDetail: function(marketData) {
		this.props.navigator.push({ id: 'DiningDetail', component: DiningDetail, title: marketData.name, marketData: marketData });
	}
});

module.exports = DiningList;