'use strict';

import React from 'react';
import {
	StyleSheet,
	View,
	Text,
	AppState,
	Navigator,
	TouchableHighlight,
	ScrollView,
	Image,
	MapView,
	ListView,
	Animated,
	RefreshControl,
	Modal
} from 'react-native';


// Node Modules
var TimerMixin = 		require('react-timer-mixin');
var Realm = 			require('realm');

// App Settings / Util / CSS
var AppSettings = 		require('../AppSettings');
var css = 				require('../styles/css');
var general = 			require('../util/general');
var logger = 			require('../util/logger');
var shuttle = 			require('../util/shuttle');

// UCSD Nodes / Shuttles
var ucsd_nodes = 		require('../json/ucsd_nodes.json');
var shuttle_routes = 	require('../json/shuttle_routes_master.json');

// Views
var ShuttleStop = 		require('./ShuttleStop');
var SurfReport = 		require('./SurfReport');
var EventDetail = 		require('./EventDetail');
var TopStoriesDetail = 	require('./TopStoriesDetail');
var DestinationDetail = require('./DestinationDetail');
var DiningList = 		require('./DiningList');
var WebWrapper = 		require('./WebWrapper');

//test

// Remove after rewriting using sortRef method
var closestShuttleStops = [];
closestShuttleStops[0] = {};
closestShuttleStops[1] = {};
closestShuttleStops[0].dist = 100000;
closestShuttleStops[1].dist = 100000;

var ucsd_node;


var Home = React.createClass({

	realm: null,
	AppSettings: null,

	mixins: [TimerMixin],

	shuttleCardRefreshInterval: 1 * 60 * 1000,		// Refresh ShuttleCard every 1 minute
	shuttleCardGPSRefreshInterval: .25 * 1000,		// Look for GPS data every 250ms (1/4s) for 15s before failing
	shuttleCardGPSRefreshLimit: 60,
	shuttleCardGPSRefreshCounter: 0,
	shuttleReloadAnim: new Animated.Value(0),
	shuttleMainReloadAnim: new Animated.Value(0),
	weatherReloadAnim: new Animated.Value(0),
	fetchEventsErrorInterval: 15 * 1000,			// Retry every 15 seconds
	fetchEventsErrorLimit: 3,
	fetchEventsErrorCounter: 0,
	fetchTopStoriesErrorInterval: 15 * 1000,		// Retry every 15 seconds
	fetchTopStoriesErrorLimit: 3,
	fetchTopStoriesErrorCounter: 0,
	eventsDefaultResults: 3,
	topStoriesDefaultResults: 3,
	nearbyMaxResults: 5,
	nearbyAnnotations: [],
	regionRefreshInterval: 60 * 1000,
	copyrightYear: new Date().getFullYear(),
	

	getInitialState: function() {

		return {
			currentAppState: AppState.currentState,
			isRefreshing: false,

			initialLoad: true,

			modalVisible: true,

			currentRegion: null,
			nearbyMarkersLoaded: false,
			nearbyLastRefresh: null,

			specialEventsCardEnabled: true,
			scrollEnabled: true,
			
			weatherData: null,
			weatherDataLoaded: false,

			surfData: null,
			surfDataLoaded: false,

			eventsDataLoaded: false,
			eventsRenderAllRows: false,
			fetchEventsErrorLimitReached: false,

			topStoriesDataLoaded: false,
			topStoriesRenderAllRows: false,
			fetchTopStoriesErrorLimitReached: false,

			shuttleRefreshTimeAgo: ' ',
			closestStop1Loaded: false,
			closestStop2Loaded: false,
			closestStop1LoadFailed: false,
			closestStop2LoadFailed: false,
			gpsLoadFailed: false,

			nearbyMinDelta: .01,
			nearbyMaxDelta: .02,

			currentPosition: null,
			initialPosition: null,

			simulatorPosition: {
				// TPCS
				//coords: { latitude: 32.890378, longitude: -117.243365 }
				// UCSD
				coords: { latitude: 32.88, longitude: -117.234 }
			},
		}
	},

	componentWillMount: function() {

		// Realm DB Init
		this.realm = new Realm({schema: [AppSettings.DB_SCHEMA], schemaVersion: 2});
		this.AppSettings = this.realm.objects('AppSettings');

		// Hide welcome modal if previously dismissed
		if (this.AppSettings.MODAL_ENABLED === false) {
			this.setState({ modalVisible: false });
		}

		// Manage App State
		AppState.addEventListener('change', this.handleAppStateChange);

		// SHUTTLE & DESTINATION CARD
		if (AppSettings.SHUTTLE_CARD_ENABLED || AppSettings.DESTINATION_CARD_ENABLED) {

			
			navigator.geolocation.getCurrentPosition(
				(initialPosition) => this.setState({initialPosition}),
				(error) => logger.custom('ERR: navigator.geolocation.getCurrentPosition2: ' + error.message),
				{enableHighAccuracy: true, timeout: 20000, maximumAge: 1000}
			);
			
			this.geolocationWatchID = navigator.geolocation.watchPosition((currentPosition) => {
				this.setState({currentPosition});
			});
			
			this.setTimeout( () => { this.updateCurrentRegion() }, 1000);
		}

		// LOAD CARDS
		this.refreshAllCards('auto');

	},
	
	componentDidMount: function() {
		logger.custom('View Loaded: Home');
	},

	componentWillUnmount: function() {
		if (AppSettings.SHUTTLE_CARD_ENABLED || AppSettings.DESTINATION_CARD_ENABLED) {
			navigator.geolocation.clearWatch(this.geolocationWatchID);
		}
		AppState.removeEventListener('change', this.handleAppStateChange);
	},

	// #1 - RENDER
	render: function() {
		return this.renderScene();
	},

	renderScene: function(route, navigator, index, navState) {

		return (
			<View style={css.main_container}>
				<ScrollView contentContainerStyle={css.scroll_main} refreshControl={
					<RefreshControl
						refreshing={this.state.isRefreshing}
						onRefresh={this.pullDownRefresh}
						tintColor="#CCC"
						title="" />
        			}>

					{this.AppSettings['0'].MODAL_ENABLED ? (
						<Modal animationType={'none'} transparent={true} visible={this.state.modalVisible}>
							<View style={css.modal_container}>
								<Text style={css.modal_text_intro}>Hello.</Text>
								<Text style={css.modal_text}>
									Thanks for trying {AppSettings.APP_NAME}!{'\n\n'}
									{AppSettings.APP_NAME} connects you to campus with:{'\n\n'}
									- location-based shuttle information{'\n'}
									- timely news and events{'\n'}
									- nearby points of interest{'\n'}
									- and we&apos;ll be adding new stuff all the time{'\n'}
								</Text>

								<TouchableHighlight underlayColor={'rgba(200,200,200,.5)'} onPress={ () => this.setModalVisible(false) }>
									<View style={css.modal_button}>
										<Text style={css.modal_button_text}>ok, let&apos;s go already</Text>
									</View>
								</TouchableHighlight>
							</View>
						</Modal>
					) : null }


 					

					{/* SPECIAL EVENTS CARD */}
					{AppSettings.PUSH_CARD_ENABLED ? (
						<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ null }>
							<Image style={[css.card_plain, css.card_special_events]} source={ require('image!special_events_placeholder') }>
								<View style={css.card_view_overlay}>
									<Text style={css.card_overlay1_text}>#WelcomeWeek</Text>
									<View style={css.card_overlay1_icons}><Image style={css.icon_fb} source={require('image!icon_fb')} /></View>
									<View style={css.card_overlay1_icons}><Image style={css.icon_twitter} source={require('image!icon_twitter')} /></View>
								</View>
							</Image>
						</TouchableHighlight>
					) : null }


					{/* SHUTTLE CARD */}
					{AppSettings.SHUTTLE_CARD_ENABLED ? (
						<View style={css.card_main}>
							<View style={css.card_title_container}>
								<Text style={css.card_title}>Shuttle Routes</Text>
								<View style={css.shuttle_card_refresh_container}>
									<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.refreshShuttleCard('manual') }>
										<Animated.Image style={[css.shuttle_card_refresh, { transform: [{ rotate: this.shuttleReloadAnim.interpolate({ inputRange: [0, 1], outputRange: ['0deg', '360deg']})}]}]} source={require('image!icon_refresh_grey')} />
									</TouchableHighlight>
								</View>
							</View>

							{this.state.closestStop1Loaded ? (
								<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoShuttleStop(closestShuttleStops[0]) }>
									<View style={css.shuttle_card_row}>
										<View style={css.shuttle_card_row_top}>
											<View style={css.shuttle_card_rt_1}></View>
											<View style={[css.shuttle_card_rt_2, { backgroundColor: closestShuttleStops[0].routeColor, borderColor: closestShuttleStops[0].routeColor }]}><Text style={css.shuttle_card_rt_2_label}>{closestShuttleStops[0].routeShortName}</Text></View>
											<View style={css.shuttle_card_rt_3}><Text style={css.shuttle_card_rt_3_label}>@</Text></View>
											<View style={css.shuttle_card_rt_4}><Text style={css.shuttle_card_rt_4_label} numberOfLines={3}>{closestShuttleStops[0].stopName}</Text></View>
											<View style={css.shuttle_card_rt_5}></View>
										</View>
										<View style={css.shuttle_card_row_bot}>
											<Text style={css.shuttle_card_row_arriving}><Text style={css.grey}>Arriving in: </Text>{closestShuttleStops[0].etaMinutes}</Text>
										</View>
									</View>
								</TouchableHighlight>
							) : null }

							{this.state.closestStop2Loaded ? (
								<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoShuttleStop(closestShuttleStops[1]) }>
									<View style={[css.shuttle_card_row, css.shuttle_card_row_border]}>
										<View style={css.shuttle_card_row_top}>
											<View style={css.shuttle_card_rt_1}></View>
											<View style={[css.shuttle_card_rt_2, { backgroundColor: closestShuttleStops[1].routeColor, borderColor: closestShuttleStops[1].routeColor }]}><Text style={css.shuttle_card_rt_2_label}>{closestShuttleStops[1].routeShortName}</Text></View>
											<View style={css.shuttle_card_rt_3}><Text style={css.shuttle_card_rt_3_label}>@</Text></View>
											<View style={css.shuttle_card_rt_4}><Text style={css.shuttle_card_rt_4_label} numberOfLines={3}>{closestShuttleStops[1].stopName}</Text></View>
											<View style={css.shuttle_card_rt_5}></View>
										</View>
										<View style={css.shuttle_card_row_bot}>
											<Text style={css.shuttle_card_row_arriving}><Text style={css.grey}>Arriving in: </Text>{closestShuttleStops[1].etaMinutes}</Text>
										</View>
									</View>
								</TouchableHighlight>
							) : null }

							{(this.state.closestStop1Loaded === false && this.state.closestStop2Loaded === false) && (!this.state.closestStop1LoadFailed || !this.state.closestStop2LoadFailed) && !this.state.gpsLoadFailed ? (
								<View style={[css.flexcenter, css.shuttle_card_row, css.shuttle_card_loading_height]}>
									<Animated.Image style={[css.card_loading_img, css.shuttlecard_loading, { transform: [{ rotate: this.shuttleMainReloadAnim.interpolate({ inputRange: [0, 1], outputRange: ['0deg', '360deg']})}]}]} source={require('image!ajax-loader4')} />
								</View>
							) : null }

							{this.state.gpsLoadFailed ? (
								<View style={[css.flexcenter, css.shuttle_card_row, css.shuttle_card_loading_height]}>
									<View style={css.shuttlecard_loading_fail}>
										<Text style={css.fs18}>Error loading Shuttle Routes.</Text>
										<Text style={[css.pt10, css.fs12, css.dgrey]}>Please ensure Location Services are enabled for {AppSettings.APP_NAME} on your device.</Text>
									</View>
								</View>
							) : null }

							{this.state.closestStop1Loaded === false && this.state.closestStop2Loaded === false &&
							 this.state.closestStop1LoadFailed && this.state.closestStop2LoadFailed ? (
								<View style={[css.flexcenter, css.shuttle_card_row, css.shuttle_card_loading_height]}>
									<View style={css.shuttlecard_loading_fail}>
										<Text style={css.fs18}>No Shuttles en Route</Text>
										<Text style={[css.pt10, css.fs12, css.dgrey]}>We were unable to locate any nearby shuttles, please try again later.</Text>
									</View>
								</View>
							) : null }

						</View>
					) : null }


					{/* WEATHER CARD */}
					{AppSettings.WEATHER_CARD_ENABLED ? (
						<View style={css.card_main}>
							<View style={css.card_title_container}>
								<Text style={css.card_title}>Weather</Text>
							</View>

							{this.state.weatherDataLoaded ? (
								<View style={css.wc_main}>

									<View style={css.wc_toprow}>
										<View style={css.wc_toprow_left}>
											<Text style={css.wc_current_temp}>{ this.state.weatherData.currently.temperature }&deg; in San Diego</Text>
											<Text style={css.wc_current_summary}>{ this.state.weatherData.currently.summary }</Text>
										</View>
										<View style={css.wc_toprow_right}>
											<Image style={css.wc_toprow_icon} source={{ uri: AppSettings.WEATHER_ICON_BASE_URL + this.state.weatherData.currently.icon + '.png' }} />
										</View>
									</View>

									<View style={css.wc_botrow}>
										<View style={css.wc_botrow_col}>
											<Text style={css.wf_dayofweek}>{this.state.weatherData.daily.data[0].dayofweek}</Text>
											<Image style={css.wf_icon} source={{ uri: AppSettings.WEATHER_ICON_BASE_URL + this.state.weatherData.daily.data[0].icon + '.png' }} />
											<Text style={css.wf_tempMax}>{this.state.weatherData.daily.data[0].tempMax}&deg;</Text>
											<Text style={css.wf_tempMin}>{this.state.weatherData.daily.data[0].tempMin}&deg;</Text>
										</View>
										<View style={css.wc_botrow_col}>
											<Text style={css.wf_dayofweek}>{this.state.weatherData.daily.data[1].dayofweek}</Text>
											<Image style={css.wf_icon} source={{ uri: AppSettings.WEATHER_ICON_BASE_URL + this.state.weatherData.daily.data[1].icon + '.png' }} />
											<Text style={css.wf_tempMax}>{this.state.weatherData.daily.data[1].tempMax}&deg;</Text>
											<Text style={css.wf_tempMin}>{this.state.weatherData.daily.data[1].tempMin}&deg;</Text>
										</View>
										<View style={css.wc_botrow_col}>
											<Text style={css.wf_dayofweek}>{this.state.weatherData.daily.data[2].dayofweek}</Text>
											<Image style={css.wf_icon} source={{ uri: AppSettings.WEATHER_ICON_BASE_URL + this.state.weatherData.daily.data[2].icon + '.png' }} />
											<Text style={css.wf_tempMax}>{this.state.weatherData.daily.data[2].tempMax}&deg;</Text>
											<Text style={css.wf_tempMin}>{this.state.weatherData.daily.data[2].tempMin}&deg;</Text>
										</View>
										<View style={css.wc_botrow_col}>
											<Text style={css.wf_dayofweek}>{this.state.weatherData.daily.data[3].dayofweek}</Text>
											<Image style={css.wf_icon} source={{ uri: AppSettings.WEATHER_ICON_BASE_URL + this.state.weatherData.daily.data[3].icon + '.png' }} />
											<Text style={css.wf_tempMax}>{this.state.weatherData.daily.data[3].tempMax}&deg;</Text>
											<Text style={css.wf_tempMin}>{this.state.weatherData.daily.data[3].tempMin}&deg;</Text>
										</View>
										<View style={css.wc_botrow_col}>
											<Text style={css.wf_dayofweek}>{this.state.weatherData.daily.data[4].dayofweek}</Text>
											<Image style={css.wf_icon} source={{ uri: AppSettings.WEATHER_ICON_BASE_URL + this.state.weatherData.daily.data[4].icon + '.png' }} />
											<Text style={css.wf_tempMax}>{this.state.weatherData.daily.data[4].tempMax}&deg;</Text>
											<Text style={css.wf_tempMin}>{this.state.weatherData.daily.data[4].tempMin}&deg;</Text>
										</View>
									</View>


									<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoSurfReport() }>
										<View style={css.weathercard_border}>
											<Text style={css.wc_surfreport_more}>Surf Report &raquo;</Text>
										</View>
									</TouchableHighlight>
								</View>
							) : null }


							{!this.state.weatherDataLoaded ? (
								<View style={[css.flexcenter, css.weatherccard_loading_height]}>
									<Animated.Image style={[css.card_loading_img, { transform: [{ rotate: this.weatherReloadAnim.interpolate({ inputRange: [0, 1], outputRange: ['0deg', '360deg']})}]}]} source={require('image!ajax-loader4')} />
								</View>
							) : null }

						</View>
					) : null }


					{/* TOP STORIES CARD */}
					{AppSettings.TOPSTORIES_CARD_ENABLED ? (
						<View style={css.card_main}>
							<View style={css.card_title_container}>
								<Text style={css.card_title}>News</Text>
							</View>

							{this.state.topStoriesDataLoaded ? (
								<View style={css.events_list}>

									{this.state.topStoriesRenderAllRows ? (
										<ListView dataSource={this.state.topStoriesDataFull} renderRow={this.renderTopStoriesRow} style={css.wf_listview} />
									) : (
										<ListView dataSource={this.state.topStoriesDataPartial} renderRow={this.renderTopStoriesRow} style={css.wf_listview} />
									)}

									{this.state.topStoriesRenderAllRows === false ? (
										<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this._setState('topStoriesRenderAllRows', true) }>
											<View style={css.events_more}>
												<Text style={css.events_more_label}>Show More News &#9660;</Text>
											</View>
										</TouchableHighlight>
									) : null }

									{this.state.topStoriesRenderAllRows === true ? (
										<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this._setState('topStoriesRenderAllRows', false) }>
											<View style={css.events_more}>
												<Text style={css.events_more_label}>Show Less News &#9650;</Text>
											</View>
										</TouchableHighlight>
									) : null }

								</View>
							) : null }

							{this.state.fetchTopStoriesErrorLimitReached ? (
								<View style={[css.flexcenter, css.pad40]}>
									<Text>Error loading content</Text>
								</View>
							) : null }

						</View>
					) : null }


					{/* EVENTS CARD */}
					{AppSettings.EVENTS_CARD_ENABLED ? (
						<View style={css.card_main}>
							<View style={css.card_title_container}>
								<Text style={css.card_title}>Campus Events</Text>
							</View>

							{this.state.eventsDataLoaded ? (
								<View style={css.events_list}>
									{this.state.eventsRenderAllRows ? (
										<ListView dataSource={this.state.eventsDataFull} renderRow={this.renderEventsRow} style={css.wf_listview} />
									) : (
										<ListView dataSource={this.state.eventsDataPartial} renderRow={this.renderEventsRow} style={css.wf_listview} />
									)}

									{this.state.eventsRenderAllRows === false ? (
										<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this._setState('eventsRenderAllRows', true) }>
											<View style={css.events_more}>
												<Text style={css.events_more_label}>Show More Events &#9660;</Text>
											</View>
										</TouchableHighlight>
									) : null }

									{this.state.eventsRenderAllRows === true ? (
										<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this._setState('eventsRenderAllRows', false) }>
											<View style={css.events_more}>
												<Text style={css.events_more_label}>Show Less Events &#9650;</Text>
											</View>
										</TouchableHighlight>
									) : null }

								</View>
							) : null }

							{this.state.fetchEventsErrorLimitReached ? (
								<View style={[css.flexcenter, css.pad40]}>
									<Text>There was a problem loading Student Events</Text>
								</View>
							) : null }

						</View>
					) : null }


					{/* DESTINATION CARD */}
					{AppSettings.DESTINATION_CARD_ENABLED ? (
						<View style={css.card_main}>
							<View style={css.card_title_container}>
								<Text style={css.card_title}>Nearby</Text>
							</View>

							<View style={css.destinationcard_bot_container}>
								<View style={css.destinationcard_map_container}>
									<MapView
										style={css.destinationcard_map}
										annotations={this.nearbyAnnotations}
										scrollEnabled={true}
										zoomEnabled={true}
										rotateEnabled={false}
										showsUserLocation={true}
										minDelta={this.nearbyMinDelta}
										maxDelta={this.nearbyMaxDelta}
										followUserLocation={true} />
								</View>

								{this.state.nearbyMarkersLoaded ? (
									<ListView dataSource={this.state.nearbyMarkersPartial} renderRow={this.renderNearbyRow} style={css.flex} />
								) : null }
							</View>
						</View>
					) : null }


					{/* DINING CARD */}
					{AppSettings.DINING_CARD_ENABLED ? (
						<View style={css.card_main}>
							<View style={css.card_title_container}>
								<Text style={css.card_title}>Dining</Text>
							</View>

							<View>
								<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoDiningList() }>
									<Image style={css.dining_card_placeholder_img} source={ require('image!dining_card_mockup')} />
								</TouchableHighlight>
							</View>
						</View>
					) : null }


					{/* FOOTER */}
					<View style={css.footer}>
						<TouchableHighlight style={css.footer_link} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoFeedbackForm() }>
							<Text style={css.footer_about}>About this app</Text>
						</TouchableHighlight>
						<Text style={css.footer_spacer}>|</Text>
						<TouchableHighlight style={css.footer_link}>
							<Text style={css.footer_copyright}>&copy; {this.copyrightYear} UC Regents</Text>
						</TouchableHighlight>
					</View>

				</ScrollView>
			</View>
		);
	},


	// #2 - REFRESH
	pullDownRefresh: function(refreshType) {
		this.setState({ isRefreshing: true });
		this.refreshAllCards(refreshType);
		this.setState({ isRefreshing: false });
	},

	refreshAllCards: function(refreshType) {
		if (!refreshType) { refreshType = 'manual'; }
		this.refreshShuttleCard(refreshType);
		this.refreshWeatherCard();
		this.refreshEventsCard();
		this.refreshTopStoriesCard();
	},

	refreshShuttleCard: function(refreshType) {
		if (AppSettings.SHUTTLE_CARD_ENABLED) {
			
			this.setState({ gpsLoadFailed: false });

			if (this.state.initialLoad) {
				general.stopReloadAnimation(this.shuttleMainReloadAnim);
				general.startReloadAnimation2(this.shuttleMainReloadAnim, 150, 60000);
			} else {
				this.setState({ initialLoad: false });
			}

			if (refreshType === 'manual') {
				this.shuttleCardGPSRefreshCounter = 0;
				general.stopReloadAnimation(this.shuttleReloadAnim);
				general.startReloadAnimation(this.shuttleReloadAnim);
			}

			this.findClosestShuttleStops(refreshType);
		}
	},

	refreshWeatherCard: function() {
		if (AppSettings.WEATHER_CARD_ENABLED) {
			general.stopReloadAnimation(this.weatherReloadAnim);
			general.startReloadAnimation2(this.weatherReloadAnim, 150, 60000);
			this.fetchWeatherData();
			this.fetchSurfData();
		}
	},

	refreshEventsCard: function() {
		if (AppSettings.EVENTS_CARD_ENABLED) {
			this.fetchEventsErrorCounter = 0;
			this.fetchEventsErrorLimitReached = false;
			this.fetchEvents();
		}
	},

	refreshTopStoriesCard: function() {
		if (AppSettings.TOPSTORIES_CARD_ENABLED) {
			this.fetchTopStoriesErrorCounter = 0;
			this.fetchTopStoriesErrorLimitReached = false;
			this.fetchTopStories();
		}
	},





	// #3 - EVENTS CARD
	fetchEvents: function() {

		fetch(AppSettings.EVENTS_API_URL, {
				headers: {
					'Cache-Control': 'no-cache'
				}
			})
			.then((response) => response.json())
			.then((responseData) => {

				var responseDataFull = responseData;
				var responseDataPartial = responseData.slice(0, this.eventsDefaultResults);

				var dsFull = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
				var dsPartial = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});

				this.setState({
					eventsDataFull: dsFull.cloneWithRows(responseDataFull),
					eventsDataPartial: dsPartial.cloneWithRows(responseDataPartial),
					eventsDataLoaded: true
				});
			})
			.catch((error) => {
				if (this.fetchEventsErrorLimit > this.fetchEventsErrorCounter) {
					this.fetchEventsErrorCounter++;
					logger.custom('ERR: fetchEvents1: refreshing again in ' + this.fetchEventsErrorInterval/1000 + ' sec');
					this.refreshEventsTimer = this.setTimeout( () => { this.fetchEvents() }, this.fetchEventsErrorInterval);
				} else {
					logger.custom('ERR: fetchEvents2: Limit exceeded - max limit:' + this.fetchEventsErrorLimit);
					this.setState({ fetchEventsErrorLimitReached: true });
				}
			})
			.done();
	},

	renderEventsRow: function(data) {
		
		var eventTitleStr = data.EventTitle.replace('&amp;','&');
		var eventDescriptionStr = data.EventDescription.replace('&amp;','&').replace(/\n.*/g,'').trim();

		if (eventDescriptionStr.length > 0) {
			if (eventTitleStr.length < 25) {
				eventDescriptionStr = eventDescriptionStr.substring(0,56) + '...';
			} else if (eventTitleStr.length < 50) {
				eventDescriptionStr = eventDescriptionStr.substring(0,28) + '...';
			} else {
				eventDescriptionStr = '';
			}
		}

		var eventDateDay;
		if (data.EventDate) {
			var eventDateDayArray = data.EventDate[0].split(', ');
			eventDateDay = eventDateDayArray[1] + ', ' + eventDateDayArray[2].substring(5,22).toLowerCase();
		} else {
			eventDateDay = 'Ongoing Event';
		}

		return (
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoEventDetail(data) }>
				<View style={css.events_list_row}>
					<View style={css.events_list_left_container}>
						<Text style={css.events_list_title}>{eventTitleStr}</Text>
						{eventDescriptionStr ? (<Text style={css.events_list_desc}>{eventDescriptionStr}</Text>) : null }
						<Text style={css.events_list_postdate}>{eventDateDay}</Text>
					</View>

					<Image style={css.events_list_image} source={{ uri: data.EventImage }} />
				</View>
			</TouchableHighlight>
		);
	},


	// #4 - NEWS CARD
	fetchTopStories: function() {

		fetch(AppSettings.NEWS_API_URL, {
				headers: {
					'Cache-Control': 'no-cache'
				}
			})
			.then((response) => response.json())
			.then((responseData) => {

				for (var i = 0; responseData.items.length > i; i++) {
					if (responseData.items[i].image) {
						var image_lg = responseData.items[i].image.replace(/-150\./,'.').replace(/_teaser\./,'.');
						if (image_lg.length > 10) {
							responseData.items[i].image_lg = image_lg;
						}
					}
				}

				var responseDataFull = responseData.items;
				var responseDataPartial = responseData.items.slice(0, this.topStoriesDefaultResults);

				var dsFull = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
				var dsPartial = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});

				this.setState({
					topStoriesDataFull: dsFull.cloneWithRows(responseDataFull),
					topStoriesDataPartial: dsPartial.cloneWithRows(responseDataPartial),
					topStoriesDataLoaded: true,
				});
			})
			.catch((error) => {
				if (this.fetchTopStoriesErrorLimit > this.fetchTopStoriesErrorCounter) {
					this.fetchTopStoriesErrorCounter++;
					logger.custom('ERR: fetchTopStories: refreshing again in ' + this.fetchTopStoriesErrorInterval/1000/60 + 'm');
					this.refreshTopStoriesTimer = this.setTimeout( () => { this.fetchTopStories() }, this.fetchTopStoriesErrorInterval);
				} else {
					logger.custom('ERR: fetchTopStories: Limit exceeded - max limit:' + this.fetchTopStoriesErrorLimit);
					this.setState({ fetchTopStoriesErrorLimitReached: true });
				}
			})
			.done();
	},

	renderTopStoriesRow: function(data) {

		var storyDate = data['date'];
		var storyDateMonth = storyDate.substring(5,7);
		var storyDateDay = storyDate.substring(8,10);

		if (storyDateMonth.substring(0,1) == '0') {
			storyDateMonth = storyDateMonth.substring(1,2);
		}
		if (storyDateDay.substring(0,1) == '0') {
			storyDateDay = storyDateDay.substring(1,2);
		}

		var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
		var storyDateMonthStr = monthNames[storyDateMonth-1];

		var storyTitle = data.title;

		var storyDescriptionStr = data.description;
		storyDescriptionStr = storyDescriptionStr.replace(/^ /g, '');

		if (storyDescriptionStr.length > 0) {
			if (storyTitle.length < 25) {
				storyDescriptionStr = storyDescriptionStr.substring(0,56).replace(/ $/,'') + '...';
			} else if (storyTitle.length < 50) {
				storyDescriptionStr = storyDescriptionStr.substring(0,28).replace(/ $/,'') + '...';
			} else {
				storyDescriptionStr = '';
			}
		}

		return (
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoTopStoriesDetail(data) }>
				<View style={css.events_list_row}>
					<View style={css.events_list_left_container}>
						<Text style={css.events_list_title}>{storyTitle}</Text>
						{storyDescriptionStr ? (
							<Text style={css.events_list_desc}>{storyDescriptionStr}</Text>
						) : null }
						<Text style={css.events_list_postdate}>{storyDateMonthStr} {storyDateDay}</Text>
					</View>

					{data.image ? (
						<Image style={css.events_list_image} source={{ uri: data.image }} />
					) : (
						<Image style={css.events_list_image} source={ require('image!MobileEvents_blank')} />
					)}

				</View>
			</TouchableHighlight>
		);
	},


	// #6 - NEARBY CARD
	getCurrentPosition: function(type) {
		if (type === 'lat') {
			if (this.state.currentPosition) {
				return this.state.currentPosition.coords.latitude;
			} else if (this.state.initialPosition) {
				return this.state.initialPosition.coords.latitude;
			} else {
				return this.state.simulatorPosition.coords.latitude;
			}
		} else if (type === 'lon') {
			if (this.state.currentPosition) {
				return this.state.currentPosition.coords.longitude;
			} else if (this.state.initialPosition) {
				return this.state.initialPosition.coords.longitude;
			} else {
				return this.state.simulatorPosition.coords.longitude;
			}
		}
	},

	updateCurrentRegion: function() {

		var closestNode = 0;
		var closestNodeDistance = 1000000;

		for (var i = 0; ucsd_nodes.length > i; i++) {
			var nodeDist = shuttle.getDistance(this.getCurrentPosition('lat'), this.getCurrentPosition('lon'), ucsd_nodes[i].lat, ucsd_nodes[i].lon);

			if (nodeDist < closestNodeDistance) {
				closestNodeDistance = nodeDist;
				closestNode = ucsd_nodes[i].id;
			}
		}

		this.setState({ currentRegion: closestNode });
		this.loadNodeRegion(closestNode);
		this.updateCurrentRegionTimer = this.setTimeout( () => { this.updateCurrentRegion() }, this.regionRefreshInterval);
	},

	loadNodeRegion: function(nodeNumber) {
		var NODE_MODULES_URL = AppSettings.NODE_MARKERS_BASE_URL + 'ucsd_node_' + nodeNumber + '.json';
		fetch(NODE_MODULES_URL, {
				method: 'GET',
				headers: {
					'Cache-Control': 'no-cache'
				}
			})
			.then((response) => response.json())
			.then((responseData) => {
				this.parseNodeRegion(responseData);
			})
			.catch((error) => {
				logger.custom('ERR: loadNodeRegion: ' + error);
			})
			.done();
	},

	parseNodeRegion: function(ucsd_node) {
		// Calc distance from markers
		for (var i = 0; ucsd_node.length > i; i++) {
			ucsd_node[i].distance = shuttle.getDistance(this.getCurrentPosition('lat'), this.getCurrentPosition('lon'), ucsd_node[i].mkrLat, ucsd_node[i].mkrLong);
		}

		ucsd_node.sort(this.sortNearbyMarkers);
		var nodeDataFull = ucsd_node;
		var nodeDataPartial = ucsd_node.slice(0, this.nearbyMaxResults);

		var dsFull = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
		var dsPartial = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});

		var farthestMarkerDist;

		this.nearbyAnnotations = [];
		for (var i = 0; ucsd_node.length > i && this.nearbyMaxResults > i; i++) {
			if (this.nearbyMaxResults === i + 1) {
				farthestMarkerDist = ucsd_node[i].distance;
				var distLatLon = Math.sqrt(Math.pow(Math.abs(this.getCurrentPosition('lat') - ucsd_node[i].mkrLat), 2) + Math.pow(Math.abs(this.getCurrentPosition('lon') - ucsd_node[i].mkrLong), 2));
				this.setState({
					nearbyMinDelta: distLatLon,
					nearbyMaxDelta: distLatLon
				});
			}

			var newAnnotations = {};
			newAnnotations.latitude = parseFloat(ucsd_node[i].mkrLat);
			newAnnotations.longitude = parseFloat(ucsd_node[i].mkrLong);
			newAnnotations.title = ucsd_node[i].title;
			newAnnotations.animateDrop = true;
			this.nearbyAnnotations.push(newAnnotations);
		}

		this.setState({
			nearbyMarkersFull: dsFull.cloneWithRows(nodeDataFull),
			nearbyMarkersPartial: dsPartial.cloneWithRows(nodeDataPartial),
			nearbyMarkersLoaded: true
		});
	},

	sortNearbyMarkers: function(a, b) {
		if (a.distance < b.distance) {
			return -1;
		} else if (a.distance > b.distance) {
			return 1;
		} else {
			return 0;
		}
	},

	renderNearbyRow: function(data) {
		return (
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoDestinationDetail(data) }>
				<View style={css.destinationcard_marker_row}>
					<Image style={css.destinationcard_icon_marker} source={require('image!icon_marker')} />
					<Text style={css.destinationcard_marker_label}>{data.title}</Text>
				</View>
			</TouchableHighlight>
		);
	},


	// SHUTTLE_CARD
	findClosestShuttleStops: function(refreshType) {

		// If running on Device, and no Current or Initial position exists, retry again in 5 sec
		if (!this.props.isSimulator && (this.state.initialPosition === null && this.state.currentPosition === null)) {
			
			general.stopReloadAnimation(this.shuttleReloadAnim);

			if (this.shuttleCardGPSRefreshCounter < this.shuttleCardGPSRefreshLimit) {
				this.shuttleCardGPSRefreshCounter++;
				//logger.log('Queueing Shuttle Card refresh (for GPS) in ' + this.shuttleCardGPSRefreshInterval/1000 + ' seconds');
				this.refreshShuttleCardTimer = this.setTimeout( () => { this.refreshShuttleCard('auto') }, this.shuttleCardGPSRefreshInterval);
			} else {
				//logger.log('Failed to obtain GPS data, setting closestStop1LoadFailed: true');
				this.setState({ gpsLoadFailed: true });
			}

		} else {

			this.shuttleCardGPSRefreshCounter = 0;
			this.shuttleRefreshTimestamp = general.getCurrentTimestamp();

			this.setState({
				closestStop1LoadFailed: false,
				closestStop2LoadFailed: false,
				shuttleRefreshTimeAgo: ' '
			});

			closestShuttleStops[0].dist = 1000000000;
			closestShuttleStops[1].dist = 1000000000;

			for (var i = 0; shuttle_routes.length > i; i++) {

				var shuttleRoute = shuttle_routes[i];

				for (var n = 0; shuttleRoute.stops.length > n; n++) {

					var shuttleRouteStop = shuttleRoute.stops[n];
					var distanceFromStop = shuttle.getDistance(this.getCurrentPosition('lat'), this.getCurrentPosition('lon'), shuttleRouteStop.lat, shuttleRouteStop.lon);
				
					// Rewrite this later using sortRef from shuttleDetail
					if (distanceFromStop < closestShuttleStops[0].dist) {
						closestShuttleStops[0].stopID = shuttleRouteStop.id;
						closestShuttleStops[0].stopName = shuttleRouteStop.name;
						closestShuttleStops[0].dist = distanceFromStop;
						closestShuttleStops[0].stopLat = shuttleRouteStop.lat;
						closestShuttleStops[0].stopLon = shuttleRouteStop.lon;
					} else if (distanceFromStop < closestShuttleStops[1].dist && closestShuttleStops[0].stopID != shuttleRouteStop.id) {
						closestShuttleStops[1].stopID = shuttleRouteStop.id;
						closestShuttleStops[1].stopName = shuttleRouteStop.name;
						closestShuttleStops[1].dist = distanceFromStop;
						closestShuttleStops[1].stopLat = shuttleRouteStop.lat;
						closestShuttleStops[1].stopLon = shuttleRouteStop.lon;
					}
				}
			}

			this.fetchShuttleArrivalsByStop(0, closestShuttleStops[0].stopID);
			this.fetchShuttleArrivalsByStop(1, closestShuttleStops[1].stopID);

			if (refreshType == 'auto') {
				//logger.log('Queueing Shuttle Card data refresh in ' + this.shuttleCardRefreshInterval/1000 + ' seconds');
				this.refreshShuttleCardTimer = this.setTimeout( () => { this.refreshShuttleCard('auto') }, this.shuttleCardRefreshInterval);
			} else {
				// If manual refresh, reset the Auto refresh timer
				this.clearTimeout(this.refreshShuttleCardTimer);
				this.refreshShuttleCardTimer = this.setTimeout( () => { this.refreshShuttleCard('auto') }, this.shuttleCardRefreshInterval);
			}
		}
	},

	fetchShuttleArrivalsByStop: function(closestStopNumber, stopID) {
		
		var SHUTTLE_STOPS_API_URL = AppSettings.SHUTTLE_STOPS_API_URL + stopID + '/arrivals';

		fetch(SHUTTLE_STOPS_API_URL, {
				method: 'GET',
				headers: {
					'Accept' : 'application/json',
					'Cache-Control': 'no-cache'
				}
			})
			.then((response) => response.json())
			.then((responseData) => {

				if (responseData.length > 0 && responseData[0].secondsToArrival) {

					var closestShuttleETA = 999999;

					for (var i = 0; responseData.length > i; i++) {

						var shuttleStopArrival = responseData[i];

						if (shuttleStopArrival.secondsToArrival < closestShuttleETA ) {
							closestShuttleETA = shuttleStopArrival.secondsToArrival;

							closestShuttleStops[closestStopNumber].etaMinutes = shuttle.getMinutesETA(responseData[i].secondsToArrival);
							closestShuttleStops[closestStopNumber].etaSeconds = shuttleStopArrival.secondsToArrival;
							closestShuttleStops[closestStopNumber].routeID = shuttleStopArrival.route.id;
							closestShuttleStops[closestStopNumber].routeName = shuttleStopArrival.route.name;
							closestShuttleStops[closestStopNumber].routeShortName = shuttleStopArrival.route.shortName;
							closestShuttleStops[closestStopNumber].routeColor = shuttleStopArrival.route.color;
						}
					}
					
					if (closestShuttleStops[closestStopNumber].routeShortName == "Campus Loop") {
						closestShuttleStops[closestStopNumber].routeShortName = "L";
					}
					closestShuttleStops[closestStopNumber].routeName = closestShuttleStops[closestStopNumber].routeName.replace(/.*\) /, '').replace(/ - .*/, '');

					if (closestStopNumber == 0) {
						this.setState({ closestStop1Loaded: true });
					} else if (closestStopNumber == 1) {
						this.setState({ closestStop2Loaded: true });
					}
					
				} else {
					throw('invalid');
				}

				general.stopReloadAnimation(this.shuttleReloadAnim);

			})
			.catch((error) => {

				logger.custom('ERR: fetchShuttleArrivalsByStop: ' + error + ' (stop: ' + closestStopNumber + ')');

				if (closestStopNumber == 0) {
					this.setState({ closestStop1LoadFailed: true });
				} else if (closestStopNumber == 1) {
					this.setState({ closestStop2LoadFailed: true });
				}

				general.stopReloadAnimation(this.shuttleReloadAnim);
			})
			.done();
	},

	// #6 - WEATHER CARD
	fetchWeatherData: function() {

		fetch(AppSettings.WEATHER_API_URL, {
				headers: {
					'Cache-Control': 'no-cache'
				}
			})
			.then((response) => response.json())
			.then((responseData) => {

				responseData.currently.temperature = Math.round(responseData.currently.temperature);
				responseData.daily.data = responseData.daily.data.slice(0,5);

				for (var i = 0; responseData.daily.data.length > i; i++) {
					var data = responseData.daily.data[i];
					var wf_date = new Date(data.time * 1000);
					var wf_days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
					var wf_day = wf_date.getDay();

					data.dayofweek = wf_days[wf_day];
					data.tempMax = Math.round(data.temperatureMax);
					data.tempMin = Math.round(data.temperatureMin);
				}

				this.setState({
					weatherData: responseData,
					weatherDataLoaded: true,
				});
			})
			.catch((error) => {
				logger.custom('ERR: fetchWeatherData: ' + error);
			})
			.done();
	},

	fetchSurfData: function() {

		fetch(AppSettings.SURF_API_URL, {
				headers: { 'Cache-Control': 'no-cache' }
			})
			.then((response) => response.json())
			.then((responseData) => {
				this.setState({
					surfData: responseData,
					surfDataLoaded: true,
				});
			})
			.catch((error) => {
				logger.custom('ERR: fetchSurfData: ' + error);
			})
			.done();
	},

	getCurrentSurfData: function() {
		if (this.state.surfDataLoaded) {
			var surfData = this.state.surfData[0].title.replace(/.* \: /g, '').replace(/ft.*/g, '').replace(/^\./g, '').replace(/^ /g, '').replace(/ $/g, '').replace(/Surf\: /g, '').trim() + "'";
			if (surfData.length <= 6) {
				return (surfData);
			} else if (surfData.indexOf('none') >= 0) {
				return '1-2\'';
			} else {
				return ;
			}
		} else {
			return;
		}
	},


	// #9 - NAVIGATOR
	gotoEventDetail: function(eventData) {
		this.props.navigator.push({ component: EventDetail, title: 'Events', eventData: eventData });
	},

	gotoTopStoriesDetail: function(topStoriesData) {
		this.props.navigator.push({ component: TopStoriesDetail, title: 'News', topStoriesData: topStoriesData });
	},

	gotoSurfReport: function() {
		this.props.navigator.push({ component: SurfReport, title: 'Surf Report', surfData: this.state.surfData });
	},

	gotoShuttleStop: function(stopData) {
		this.props.navigator.push({ component: ShuttleStop, title: 'Shuttle', stopData: stopData });
	},
	
	gotoDestinationDetail: function(destinationData) {
		destinationData.currentLat = this.getCurrentPosition('lat');
		destinationData.currentLon = this.getCurrentPosition('lon');

		destinationData.mkrLat = parseFloat(destinationData.mkrLat);
		destinationData.mkrLong = parseFloat(destinationData.mkrLong);

		destinationData.distLatLon = Math.sqrt(Math.pow(Math.abs(this.getCurrentPosition('lat') - destinationData.mkrLat), 2) + Math.pow(Math.abs(this.getCurrentPosition('lon') - destinationData.mkrLong), 2));
		this.props.navigator.push({ component: DestinationDetail, title: destinationData.title, destinationData: destinationData });
	},

	gotoFeedbackForm: function() {
		this.props.navigator.push({ component: WebWrapper, title: 'Feedback', webViewURL: AppSettings.FEEDBACK_URL });
	},

	gotoPrivacyPolicy: function() {
		this.props.navigator.push({ component: WebWrapper, title: 'About', webViewURL: AppSettings.PRIVACY_POLICY_URL });
	},

	gotoScheduleDetail: function() {
		this.props.navigator.push({ component: ScheduleDetail, title: 'Schedule' });
	},

	gotoDiningList: function() {
		this.props.navigator.push({ component: DiningList, title: '64 Degrees' });
	},

	

	

	
	// #10 - MISC
	_setState: function(myKey, myVal) {
		var state = {};
		state[myKey] = myVal;
		this.setState(state);
	},

	// Welcome Modal
	setModalVisible: function(visible) {
		this.realm.write(() => {
			this.realm.create('AppSettings', { id: 1, MODAL_ENABLED: false }, true);
		});
		this.setState({ modalVisible: visible });
	},

	handleAppStateChange: function(currentAppState) {
		this.setState({ currentAppState, });
		if (currentAppState === 'active') {
			this.refreshAllCards('auto');
		}
	},

});

module.exports = Home;