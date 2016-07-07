/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  Navigator,
  Platform,
} from 'react-native';

var Realm = require('realm');

var logger = require('./app/util/logger');
var AppSettings = require('./app/AppSettings');
var Home = require('./app/views/Home');
var SurfReport = require('./app/views/SurfReport');
var EventDetail = require('./app/views/EventDetail');
var TopStoriesDetail = require('./app/views/TopStoriesDetail');
var ShuttleStop = require('./app/views/ShuttleStop');
var DestinationSearch = require('./app/views/DestinationSearch');
var DestinationDetail = require('./app/views/DestinationDetail');

var nowucsandiego = React.createClass({

	realm: null,
	AppSettings: null,

	componentWillMount: function() {

		// Realm DB Setup
		this.realm = new Realm({schema: [AppSettings.DB_SCHEMA], schemaVersion: 2});
		this.AppSettings = this.realm.objects('AppSettings');

		if (this.AppSettings.length === 0) {
			this.realm.write(() => {
				this.realm.create('AppSettings', { id: 1 });
			});
		}
	},

  render: function() {

  		console.log('test DEBUG ')

	  return (
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
