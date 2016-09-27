'use strict'

import React from 'react'
import {
	View,
	ListView,
	Text,
	TouchableHighlight,
} from 'react-native';

import Card from '../card/Card';
import CardComponent from '../card/CardComponent';
import ShuttleService from '../../services/shuttleService';
import ShuttleOverview from './ShuttleOverview';

var css = require('../../styles/css');
var logger = require('../../util/logger');
var shuttle = require('../../util/shuttle');

var shuttle_routes = 	require('../../json/shuttle_routes_master.json');

export default class ShuttleCard extends CardComponent {

  constructor(props) {
		super(props);

		this.shuttleClosestStops = [{ dist: 100000000 },{ dist: 100000000 }];

    this.state = {
			isRefreshing: false,
			closestStop1Loaded: false,
			closestStop2Loaded: false,
			closestStop1LoadFailed: false,
			closestStop2LoadFailed: false,
			shuttleData: [],
			defaultPosition: {
				coords: { latitude: 32.88, longitude: -117.234 }
			},
    };
  }

	componentDidMount() {
		this.refresh();
	}

	componentWillReceiveProps(nextProps) {
		if (nextProps.location !== this.props.location) {
			this.refresh(); //refresh with new location
		}
	}

  refresh = () => {
		if (!this.state.isRefreshing) {
			this.setState({ isRefreshing: true });

			this.findClosestShuttleStops('auto');
		}
  }

  render() {
	return (
		<Card title='Shuttle' cardRefresh={this.refresh} isRefreshing={this.state.isRefreshing}>
      <View>
				{this.state.closestStop1Loaded ? (
					<ShuttleOverview stopData={this.shuttleClosestStops[0]} shuttleData={this.state.shuttleData[0]} />
				) : null }
				{this.state.closestStop2Loaded ? (
					<ShuttleOverview stopData={this.shuttleClosestStops[1]} shuttleData={this.state.shuttleData[1]} />
				) : null }
      </View>
		</Card>
	  );
	}

	// SHUTTLE_CARD
	findClosestShuttleStops = (refreshType) => {

		logger.log('Home: findClosestShuttleStops');

		this.setState({
			closestStop1LoadFailed: false,
			closestStop2LoadFailed: false
		});

		this.shuttleClosestStops[0].dist = 1000000000;
		this.shuttleClosestStops[1].dist = 1000000000;

		for (var i = 0; shuttle_routes.length > i; i++) {

			var shuttleRoute = shuttle_routes[i];

			for (var n = 0; shuttleRoute.stops.length > n; n++) {

				var shuttleRouteStop = shuttleRoute.stops[n];
				var distanceFromStop = shuttle.getDistance(this.getCurrentPosition('lat'), this.getCurrentPosition('lon'), shuttleRouteStop.lat, shuttleRouteStop.lon);

				// Rewrite this later using sortRef from shuttleDetail
				if (distanceFromStop < this.shuttleClosestStops[0].dist) {
					this.shuttleClosestStops[0].stopID = shuttleRouteStop.id;
					this.shuttleClosestStops[0].stopName = shuttleRouteStop.name;
					this.shuttleClosestStops[0].dist = distanceFromStop;
					this.shuttleClosestStops[0].stopLat = shuttleRouteStop.lat;
					this.shuttleClosestStops[0].stopLon = shuttleRouteStop.lon;
				} else if (distanceFromStop < this.shuttleClosestStops[1].dist && this.shuttleClosestStops[0].stopID != shuttleRouteStop.id) {
					this.shuttleClosestStops[1].stopID = shuttleRouteStop.id;
					this.shuttleClosestStops[1].stopName = shuttleRouteStop.name;
					this.shuttleClosestStops[1].dist = distanceFromStop;
					this.shuttleClosestStops[1].stopLat = shuttleRouteStop.lat;
					this.shuttleClosestStops[1].stopLon = shuttleRouteStop.lon;
				}
			}
		}

		this.fetchShuttleArrivalsByStop(0, this.shuttleClosestStops[0].stopID);
		this.fetchShuttleArrivalsByStop(1, this.shuttleClosestStops[1].stopID);

		// TODO: refresh timer
		// if (refreshType == 'auto') {
		// 	//logger.log('Queueing Shuttle Card data refresh in ' + this.shuttleCardRefreshInterval/1000 + ' seconds');
		// } else {
		// 	// If manual refresh, reset the Auto refresh timer
		// 	this.clearTimeout(this.refreshShuttleCardTimer);
		// }
		// if (general.platformAndroid() || AppSettings.NAVIGATOR_ENABLED) {
		// 	//do nothing
		// }
		// else {
		// 	this.props.new_timeout("shuttle", () => { this.refreshShuttleCard('auto') }, this.shuttleCardRefreshInterval);
		// }
	}

	getCurrentPosition = (type) => {
		if (type === 'lat') {
			if (this.props.location) {
				return this.props.location.coords.latitude;
			} else {
				return this.state.defaultPosition.coords.latitude;
			}
		} else if (type === 'lon') {
			if (this.props.location) {
				return this.props.location.coords.longitude;
			} else {
				return this.state.defaultPosition.coords.longitude;
			}
		}
	}

	fetchShuttleArrivalsByStop = (closestStopNumber, stopID) => {
			ShuttleService.FetchShuttleArrivalsByStop(stopID)
			.then((responseData) => {
				if (responseData.length > 0 && responseData[0].secondsToArrival) {
					this.setState({shuttleData : responseData});
					var closestShuttleETA = 999999;

					for (var i = 0; responseData.length > i; i++) {

						var shuttleStopArrival = responseData[i];

						if (shuttleStopArrival.secondsToArrival < closestShuttleETA ) {
							closestShuttleETA = shuttleStopArrival.secondsToArrival;

							this.shuttleClosestStops[closestStopNumber].etaMinutes = shuttle.getMinutesETA(responseData[i].secondsToArrival);
							this.shuttleClosestStops[closestStopNumber].etaSeconds = shuttleStopArrival.secondsToArrival;
							this.shuttleClosestStops[closestStopNumber].routeID = shuttleStopArrival.route.id;
							this.shuttleClosestStops[closestStopNumber].routeName = shuttleStopArrival.route.name;
							this.shuttleClosestStops[closestStopNumber].routeShortName = shuttleStopArrival.route.shortName;
							this.shuttleClosestStops[closestStopNumber].routeColor = shuttleStopArrival.route.color;
						}
					}

					if (this.shuttleClosestStops[closestStopNumber].routeShortName == "Campus Loop") {
						this.shuttleClosestStops[closestStopNumber].routeShortName = "L";
					}
					this.shuttleClosestStops[closestStopNumber].routeName = this.shuttleClosestStops[closestStopNumber].routeName.replace(/.*\) /, '').replace(/ - .*/, '');

					if (closestStopNumber == 0) {
						this.setState({ closestStop1Loaded: true });
					} else if (closestStopNumber == 1) {
						this.setState({ closestStop2Loaded: true });
					}

				} else {
					throw('Invalid response');
				}

				this.setState({ isRefreshing: false });
			})
			.catch((error) => {

				logger.error('ERR: fetchShuttleArrivalsByStop: ' + error + ' (stop: ' + closestStopNumber + ')');

				if (closestStopNumber == 0) {
					this.setState({ closestStop1LoadFailed: true });
				} else if (closestStopNumber == 1) {
					this.setState({ closestStop2LoadFailed: true });
				}

				this.setState({ isRefreshing: false });
			})
			.done();
	}

	gotoShuttleStop = (stopData, shuttleData) => {
		this.props.navigator.push({ id: 'ShuttleStop', name: 'Shuttle Stop', component: ShuttleStop, title: 'Shuttle',stopData: stopData, currentPosition: this.state.currentPosition, shuttleData: shuttleData });
	}
}
