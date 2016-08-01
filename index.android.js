import React, { Component } from 'react';
import {
	AppRegistry,
	Navigator,
	Platform,
	Alert,
	Text,
} from 'react-native';

var Realm = require('realm');

var logger = require('./app/util/logger');
var AppSettings = require('./app/AppSettings');
var Home = require('./app/views/Home');
var SurfReport = require('./app/views/SurfReport');
var EventDetail = require('./app/views/events/EventDetail');
var TopStoriesDetail = require('./app/views/TopStoriesDetail');
var ShuttleStop = require('./app/views/ShuttleStop');
var DestinationSearch = require('./app/views/DestinationSearch');
var DestinationDetail = require('./app/views/DestinationDetail');
const Permissions = require('react-native-permissions');

var nowucsandiego = React.createClass({

	realm: null,
	AppSettings: null,

	getInitialState() {
		return {
			cameraPermission: "undetermined",
			locationPermission: "undetermined",
		};
	},

	//check the status of a single permission
	componentDidMount() {
		Permissions.getPermissionStatus('location')
		.then(response => {
			//response is one of: 'authorized', 'denied', 'restricted', or 'undetermined'
			//this.setState({ locationPermission: response })
			if(response != 'authorized') {
				this._alertForLocationPermission();
			}
		});
	},

	componentWillMount: function() {
		//this._alertForLocationPermission()
		// Realm DB Setup
		this.realm = new Realm({schema: [AppSettings.DB_SCHEMA], schemaVersion: 2});
		this.AppSettings = this.realm.objects('AppSettings');

		if (this.AppSettings.length === 0) {
			this.realm.write(() => {
				this.realm.create('AppSettings', { id: 1 });
			});
		}
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
		//this._alertForLocationPermission()
		console.log('test DEBUG ')

		return (//<Text>Hello world!</Text>
			<Navigator initialRoute={{id: 'Home', name: 'Home'}} renderScene={this.renderScene} />
		);
	},


	renderScene: function(route, navigator, index, navState) {

		switch (route.id) {
			case 'Home':          return (<Home route={route} navigator={navigator} isSimulator={this.props.isSimulator} />);
			
			case 'SurfReport':        return (<SurfReport route={route} navigator={navigator} />);

			case 'EventDetail':       return (<EventDetail route={route} navigator={navigator} />);

			case 'TopStoriesDetail':    return (<TopStoriesDetail route={route} navigator={navigator} />);

			case 'ShuttleStop':       return (<ShuttleStop route={route} navigator={navigator} isSimulator={this.props.isSimulator} />);
			//case 'ShuttleStop2':      return (<ShuttleStop2 route={route} navigator={navigator} isSimulator={this.props.isSimulator} />);

			case 'WeatherForecast':     return (<WeatherForecast route={route} navigator={navigator} />);

			case 'DestinationSearch':     return (<DestinationSearch route={route} navigator={navigator} />);
			case 'DestinationDetail':     return (<DestinationDetail route={route} navigator={navigator} />);
			/*
			case 'DiningList':        return (<DiningList route={route} navigator={navigator} />);
			case 'DiningDetail':      return (<DiningDetail route={route} navigator={navigator} />);

			case 'ScheduleDetail':      return (<ScheduleDetail route={route} navigator={navigator} />);

			case 'NoNavigatorPage':     return (<NoNavigatorPage route={route} navigator={navigator} />);
			*/

			default:            return (<Home route={route} navigator={navigator} />);
		}
	},


});

AppRegistry.registerComponent('nowucsandiego', () => nowucsandiego);
