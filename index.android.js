import React, { Component } from 'react';
import {
	AppRegistry,
	Navigator,
	Platform,
	Alert,
	Text,
	TouchableHighlight,
	BackAndroid,
} from 'react-native';

var logger = require('./app/util/logger');
var AppSettings = require('./app/AppSettings');
var Home = require('./app/views/Home');
var EventDetail = require('./app/views/events/EventDetail');
var TopStoriesDetail = require('./app/views/topStories/TopStoriesDetail');
var ShuttleStop = require('./app/views/ShuttleStop');
var DestinationSearch = require('./app/views/DestinationSearch');
var DestinationDetail = require('./app/views/DestinationDetail');
const Permissions = require('react-native-permissions');
var SurfReport = require('./app/views/weather/SurfReport');

import WelcomeWeekView from './app/views/welcomeWeek/WelcomeWeekView';
var general = require('./app/util/general');
import NavigationBarWithRouteMapper from './app/views/NavigationBarWithRouteMapper';

var nowucsandiego = React.createClass({

	getInitialState() {
		return {
			cameraPermission: "undetermined",
			locationPermission: "undetermined",
			pauseRefresh: false,
		};
	},

	//check the status of a single permission
	componentDidMount() {
		console.log("Mounted");
		/*
		Permissions.getPermissionStatus('location')
		.then(response => {
			console.log("Permission: " + response);
			//response is one of: 'authorized', 'denied', 'restricted', or 'undetermined'
			//this.setState({ locationPermission: response })
			if(response != 'authorized') {
				this._alertForLocationPermission();
			}
		});*/

		// Listen to route focus changes
		// Should be a better way to do this...
		this.refs.navRef.refs.navRef.navigationContext.addListener('willfocus', (event) => {
			const route = event.data.route;
			console.log("Willfocus: " + JSON.stringify(route.id));

			// Make sure renders/card refreshes are only happening when in home route
			if(route.id === "Home") {
				this.setState({pauseRefresh: false});
			}
			else {
				this.setState({pauseRefresh: true});
			}
		});

		// Listen to back button on Android
		BackAndroid.addEventListener('hardwareBackPress', () => {
			//console.log("Backbutton: " + this.refs.navRef.navigationContext.route);
			if(this._notInHome()) {
				this.refs.navRef.refs.navRef.pop();
				return true;
			}
			else {
				BackAndroid.exitApp();
				return false;
			}
		});
	},

	//request permission to access location
	_requestPermission() {
	Permissions.requestPermission('location')
		.then(response => {
			//returns once the user has chosen to 'allow' or to 'not allow' access
			//response is one of: 'authorized', 'denied', 'restricted', or 'undetermined'
			this.setState({ locationPermission: response })
		});
	},

	//check the status of multiple permissions
	_checkCameraAndLocation() {
		Permissions.checkMultiplePermissions(['camera', 'photo'])
			.then(response => {
				//response is an object mapping type to permission
				this.setState({ 
				cameraPermission: response.camera,
				locationPermission: response.location,
			})
		});
	},

	_alertForLocationPermission() {
		Alert.alert(
			'Can we access your location?',
			'We need to spy on you.',
			[
				{text: 'No way', onPress: () => console.log('permission denied'), style: 'cancel'},
				//this.state.locationPermission == 'undetermined'? 
				{text: 'OK', onPress: this._requestPermission.bind(this)}
				//: {text: 'Open Settings', onPress: Permissions.openSettings}
			]
		)
	},

	render: function() {
		return (
			<NavigationBarWithRouteMapper
				ref="navRef"
				route={{id: 'Home', name: 'Home', title: 'now@ucsandiego'}}
				renderScene={this.renderScene}
			/>
		);
	},


	renderScene: function(route, navigator, index, navState) {
		console.log("Changing route: " + route.id);

		switch (route.id) {
			case 'Home': 				return (<Home route={route} navigator={navigator} pauseRefresh={this.state.pauseRefresh}/>);
			case 'ShuttleStop': 		return (<ShuttleStop route={route} navigator={navigator} />);
			case 'SurfReport': 			return (<SurfReport route={route} navigator={navigator} />);
			case 'TopStoriesDetail': 	return (<TopStoriesDetail route={route} navigator={navigator} />);
			case 'EventDetail': 		return (<EventDetail route={route} navigator={navigator} />);
			case 'WebWrapper': 			return (<WebWrapper route={route} navigator={navigator} />);
			case 'WelcomeWeekView': 	return(<WelcomeWeekView route={route} navigator={navigator} />);
			case 'DestinationDetail': 	return (<DestinationDetail route={route} navigator={navigator} />);
			default: 					return (<Home route={route} navigator={navigator} />);
		}
	},

	// Probably have a better way to do this in the future
	_notInHome: function() {
		return this.state.pauseRefresh;
	}

});

AppRegistry.registerComponent('nowucsandiego', () => nowucsandiego);
