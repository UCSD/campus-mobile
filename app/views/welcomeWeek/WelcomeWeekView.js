/**
 * View for Welcome Week events
 * Triggered by onPress from Special Events Card in Home.js
**/

import React, { Component } from 'react';
import {
	ListView,
	Text,
	View,
	TouchableOpacity,
	StyleSheet,
	ScrollView,
} from 'react-native';

import TopStoriesService from '../../services/topStoriesService';
//import WelcomeWeekList from './WelcomeWeekList';

var logger = require('../../util/logger');

const collegeNames = [
	{ name: "ERC", id: "ERC:vinavfnjrfbzr" }, 
	{ name: "Marshall", id: "Marshall:vinavfnjrfbzr" },
	{ name: "Muir", id: "Muir:vinavfnjrfbzr" },
	{ name: "Revelle", id: "Revelle:vinavfnjrfbzr" },
	{ name: "Sixth", id: "Sixth:vinavfnjrfbzr" },
	{ name: "Warren", id: "Warren:vinavfnjrfbzr" },
];

export default class WelcomeWeekView extends Component {
	
	/**
	 * Represents view for Welcome Week events
	 * @param { Object[] } props - An array of properties passed in
	**/
	constructor(props) {
		super(props);

		this.fetchErrorInterval =  15 * 1000;			// Retry every 15 seconds
		this.fetchErrorLimit = 3;
		this.fetchErrorCounter = 0;

		var getSectionData = (dataBlob, sectionID) => {
			return dataBlob[sectionID];
		}

		var getRowData = (dataBlob, sectionID, rowID) => {
			console.log("Blob:\n" + JSON.stringify(dataBlob));
			return dataBlob[sectionID + ':' + rowID];
		}

		this.state = {
			welcomeWeekData: {},
			fetchErrorLimitReached: false,
			
			loaded : false,
			dataSource : new ListView.DataSource({
				getSectionData : getSectionData,
				getRowData : getRowData,
				rowHasChanged : (row1, row2) => row1 !== row2,
				sectionHeaderHasChanged : (s1, s2) => s1 !== s2
			})
		}
	}

	/**
	 * Invoked before render
	**/
	componentWillMount() {
		
	}

	/**
	 * Invoked after render
	**/
	componentDidMount() {
		this._fetchData();
	}

	/**
	 * Called after state change
	 * @return bool whether the component should re-render.
	**/
	shouldComponentUpdate(nextProps, nextState) {
		console.log('shouldComponentUpdate WelcomeView');
		return true;
	}

	/**
	 * Invoked before component is unmounted from DOM
	**/
	componentWillUnmount() {

	}

	// Generates a unique ID
	// Used for Card keys
	_generateUUID() {
		var d = new Date().getTime();
		if(window.performance && typeof window.performance.now === "function") {
			d += performance.now(); //use high-precision timer if available
		}
		var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
			var r = (d + Math.random()*16)%16 | 0;
			d = Math.floor(d/16);
			return (c=='x' ? r : (r&0x3|0x8)).toString(16);
		});
		return uuid;
	}

	_fetchData () {
		// Fetch data from API
		TopStoriesService.FetchTopStories()
		.then((responseData) => {
			console.log(JSON.stringify(collegeNames));

			var colleges = collegeNames, // Probably going to get from proper feed
			length = collegeNames.length,
			dataBlob = {},
			sectionIDs = [],
			rowIDs = [],
			college,
			events,
			eventLength,
			event,
			i,
			j;

			//colleges[0]['events'] = responseData; // temp

			for(i = 0; i < length; i++) {
				college = colleges[i];

				sectionIDs.push(college.id);
				console.log("College: " + colleges[i].name);
				dataBlob[college.id] = colleges[i].name;

				if( i === 0 ) {
					events = responseData['items'];
				}
				//events = college.events;
				else {
					rowIDs[i] = "blah";
					continue;
				}
				eventLength = events.length;

				rowIDs[i] = [];

				for(j = 0; j < eventLength; j++) {
					event = events[j];
					eventID = this._generateUUID(); // Might need different way to make ids, maybe req id from feeds?
					rowIDs[i].push(eventID);

					dataBlob[college.id + ':' + eventID] = event;
				}

			}

			this.setState({
				dataSource : this.state.dataSource.cloneWithRowsAndSections(dataBlob, sectionIDs, rowIDs),
				loaded     : true
			});
		})
		.catch((error) => {
			logger.error(error);
			if (this.fetchErrorLimit > this.fetchErrorCounter) {
				this.fetchErrorCounter++;
				logger.log('ERR: fetchTopStories: refreshing again in ' + this.fetchErrorInterval/1000 + ' sec');
				this.refreshTimer = setTimeout( () => { this.refresh() }, this.fetchErrorInterval);
			} else {
				logger.log('ERR: fetchTopStories: Limit exceeded - max limit:' + this.fetchErrorLimit);
				this.setState({ fetchErrorLimitReached: true });
			}
		})
		.done();   
	}

	render() {
		if (!this.state.loaded) {
			return this.renderLoadingView();
		}

		return this.renderListView();
	}

	renderLoadingView() {
		return (
			<View>
				<Text>IM LOADING</Text>
			</View>
		);
	}

	renderListView() {
		return (
			<View style={styles.container}>
				<View style={styles.header}>
					<Text style={styles.headerText}>Welcome Week</Text>
				</View>
				<ListView
					dataSource = {this.state.dataSource}
					style      = {styles.listview}
					renderRow  = {this._renderRow}
					renderSectionHeader = {this._renderSectionHeader}
				/>
			</View>
		);
	}

	_renderRow(rowData, sectionID, rowID) {
		var title;
		console.log("renderRow: " + sectionID + ":" + rowID);
		if(rowData === undefined) {
			title = "Placeholder";
		}
		else {
			title = rowData.title;
		}

		return (
			<TouchableOpacity onPress={() => this.onPressRow(rowData, sectionID)}>
				<View style={styles.rowStyle}>
					<Text style={styles.rowText}>{title}</Text>        
				</View>
			</TouchableOpacity>
		);
	}

	_renderSectionHeader(sectionData, sectionID) {
		return (
			<View>
				<Text style={styles.text}>{sectionData}</Text>
			</View>
		); 
	}
}

var styles = StyleSheet.create({
    container: {
        flex: 1
    },
    activityIndicator: {
        alignItems: 'center',
        justifyContent: 'center',
    },
    header: {
        height: 60,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#3F51B5',
        flexDirection: 'column',
        paddingTop: 25
    },
    headerText: {
        fontWeight: 'bold',
        fontSize: 20,
        color: 'white'
    },
    text: {
        color: 'white',
        backgroundColor: '#3F51B5',
        paddingHorizontal: 8,
        fontSize: 16
    },
    rowStyle: {
        paddingVertical: 20,
        paddingLeft: 16,
        borderTopColor: 'white',
        borderLeftColor: 'white',
        borderRightColor: 'white',
        borderBottomColor: '#E0E0E0',
        borderWidth: 1
    },
    rowText: {
        color: '#212121',
        fontSize: 16
    },
    subText: {
        fontSize: 14,
        color: '#757575'
    },
    section: {
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'flex-start',
        padding: 6,
        backgroundColor: '#2196F3'
    }
});