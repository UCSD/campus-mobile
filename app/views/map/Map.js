import React from 'react'
import {
	View,
	ScrollView,
	Text,
	TouchableOpacity,
	BackHandler,
} from 'react-native'
import { connect } from 'react-redux'
import MapView from 'react-native-maps'
import { checkGooglePlayServices, openGooglePlayUpdate } from 'react-native-google-api-availability-bridge'
import Toast from 'react-native-simple-toast'

import SearchResultsBar from './SearchResultsBar'
import SearchNavButton from './SearchNavButton'
import SearchShuttleButton from './SearchShuttleButton'
import SearchBar from './SearchBar'
import SearchMap from './SearchMap'
import SearchResults from './SearchResults'
import SearchHistoryCard from './SearchHistoryCard'
import SearchSuggest from './SearchSuggest'
import SearchShuttleMenu from './SearchShuttleMenu'
import AppSettings from '../../AppSettings'
import css from '../../styles/css'
import LAYOUT from '../../styles/LayoutConstants'
import logger from '../../util/logger'
import { gotoNavigationApp, platformAndroid } from '../../util/general'

export class Map extends React.Component {
	static navigationOptions = {
		title: 'Map',
	}

	constructor(props) {
		super(props)

		this.state = {
			toggledRoute: null,
			searchInput: null,
			selectedResult: 0,
			allowScroll: false,
			iconStatus: 'search',
			showBar: false,
			showShuttle: true,
			showNav: false,
			vehicles: {},
			updatedGoogle: true,
		}
	}

	componentWillMount() {
		if (platformAndroid()) {
			checkGooglePlayServices((result) => {
				if (result === 'update') {
					this.setState({ updatedGoogle: false })
				}
			})
		}

		if (this.props.toggles) {
			Object.keys(this.props.toggles).forEach((route) => {
				if (this.props.toggles[route]) {
					this.state.currentToggledRoute = route
				}
			})
		}
	}

	componentDidMount() {
		logger.ga('View mounted: Full Map View')
		BackHandler.addEventListener('hardwareBackPress', this.pressIcon)
	}

	componentWillReceiveProps(nextProps) {
		// Clear search results when navigating away
		if (!nextProps.navigation.isFocused()) {
			this.props.clearSearch()
			this.setState({ searchInput: null })
		}

		if (nextProps.toggles) {
			// Loop thru every vehicle
			Object.keys(nextProps.toggles).forEach((route) => {
				if (nextProps.toggles[route] === true && Array.isArray(nextProps.vehicles[route])) {
					if (this.state.vehicles[route]) {
						nextProps.vehicles[route].forEach((nextVehicle) => {
							this.state.vehicles[route].forEach((currVehicle) => {
								if (nextVehicle.id === currVehicle.id &&
									(nextVehicle.lat !== currVehicle.lat || nextVehicle.lon !== currVehicle.lon)) {
									// Animate vehicle movement
									currVehicle.animated.timing({
										latitude: nextVehicle.lat,
										longitude: nextVehicle.lon,
										duration: 500
									}).start()
								}
							})
						})
					} else {
						// Make Animated values
						nextProps.vehicles[route].forEach((nextVehicle) => {
							nextVehicle.animated = new MapView.AnimatedRegion({
								latitude: nextVehicle.lat,
								longitude: nextVehicle.lon,
							})
						})

						const newVehicles = this.state.vehicles
						newVehicles[route] = nextProps.vehicles[route]

						this.setState({ vehicles: newVehicles })
					}
				}
			})
		}

		if (this.state.iconStatus === 'load' && nextProps.search_results) {
			this.setState({ iconStatus: 'search' })
		}
	}

	shouldComponentUpdate(nextProps, nextState) {
		// Don't re-render if location hasn't changed
		if (((this.props.location.coords.latitude !== nextProps.location.coords.latitude) ||
			(this.props.location.coords.longitude !== nextProps.location.coords.longitude)) ||
			this.state !== nextState ||
			this.props.search_results !== nextProps.search_results ||
			this.props.search_history.length !== nextProps.search_history.length) {
			return true
		} else {
			return false
		}
	}

	componentWillUnmount() {
		BackHandler.removeEventListener('hardwareBackPress', this.pressIcon)
		clearTimeout(this.timer)
		this.props.clearSearch()
	}

	// Returns true so router-flux back handler is ignored
	pressIcon = () => {
		if (this.state.iconStatus === 'back') {
			this.setState({
				iconStatus: 'search',
				showBar: (this.props.search_results !== null),
				showShuttle: true,
				showNav: true,
			})
			this.scrollRef.scrollTo({ x: 0, y: 0, animated: true })
			this.barRef.blur()
			return true
		} else {
			return false
		}
	}

	gotoResults = () => {
		this.setState({
			iconStatus: 'back',
			showBar: false,
			showShuttle: false,
			showNav: false
		})
		this.scrollRef.scrollTo({ x: 0, y: LAYOUT.MAP_HEIGHT, animated: true })
	}

	focusSearch = () => {
		this.scrollRef.scrollTo({ x: 0, y: 2 * (LAYOUT.MAP_HEIGHT), animated: true })
		this.setState({
			iconStatus: 'back',
			showBar: false,
			showShuttle: false,
			showNav: false,
		})
	}

	gotoShuttleSettings = () => {
		this.setState({
			iconStatus: 'back',
			showBar: false,
			showShuttle: false,
			showNav: false,
		})
		this.scrollRef.scrollTo({ x: 0, y: 3 * (LAYOUT.MAP_HEIGHT), animated: true })
	}

	gotoNavigationApp = () => {
		if (this.props.search_results && this.state.showNav) {
			gotoNavigationApp(this.props.search_results[this.state.selectedResult].mkrLat, this.props.search_results[this.state.selectedResult].mkrLong)
		} else {
			// Do nothing, this shouldn't be reached
		}
	}

	updateSearch = (text) => {
		if (text && text.trim() !== '') {
			this.props.fetchSearch(text, this.props.location)
			this.scrollRef.scrollTo({ x: 0, y: 0, animated: true })
			this.barRef.blur()

			this.setState({
				searchInput: text,
				showBar: true,
				iconStatus: 'load',
				showShuttle: true,
				showNav: true,
				selectedResult: 0
			})

			this.timer = setTimeout(this.searchTimeout, 5000)
		}
	}

	searchTimeout = () => {
		if (!this.props.search_results) {
			Toast.showWithGravity('No results found for your search.', Toast.SHORT, Toast.BOTTOM)
			this.setState({ iconStatus: 'search' })
		}
	}

	updateSearchSuggest = (text) => {
		this.props.fetchSearch(text, this.props.location)
		this.scrollRef.scrollTo({ x: 0, y: 0, animated: true })
		this.barRef.blur()

		this.setState({
			searchInput: text,
			showBar: true,
			iconStatus: 'load',
			showShuttle: true,
			showNav: true,
			selectedResult: 0
		})
	}

	updateSelectedResult = (index) => {
		const newSelect = index
		this.setState({
			iconStatus: 'search',
			selectedResult: newSelect,
			showBar: true,
			showShuttle: true,
			showNav: true,
		})
		this.scrollRef.scrollTo({ x: 0, y: 0, animated: true })
	}

	toggleRoute = (route) => {
		this.pressIcon()
		this.props.toggle(route)
		if (this.state.currentToggledRoute === route) {
			this.setState({ vehicles: {}, currentToggledRoute: null })
		} else {
			this.setState({	vehicles: {}, currentToggledRoute: route })
		}
	}

	render() {
		if (platformAndroid() && !this.state.updatedGoogle) {
			return (
				<View style={css.map_nogoogleplay}>
					<Text>Please update your Google Play Services and restart the {AppSettings.APP_NAME} app to use Map Search.</Text>
					<TouchableOpacity underlayColor="rgba(200,200,200,.1)" onPress={() => openGooglePlayUpdate()}>
						<View style={css.eventdetail_readmore_container}>
							<Text style={css.eventdetail_readmore_text}>Update Google Play Services</Text>
						</View>
					</TouchableOpacity>
				</View>
			)
		} else if (this.props.location.coords) {
			let polylines = null
			if (this.state.currentToggledRoute) {
				polylines = this.props.routes[this.state.currentToggledRoute].polylines
			}
			return (
				<View>
					<SearchNavButton
						visible={(this.state.showNav && this.props.search_results !== null)}
						onPress={this.gotoNavigationApp}
					/>
					<SearchShuttleButton
						visible={this.state.showShuttle}
						onPress={this.gotoShuttleSettings}
					/>
					<SearchBar
						update={this.updateSearch}
						onFocus={this.focusSearch}
						pressIcon={this.pressIcon}
						iconStatus={this.state.iconStatus}
						searchInput={this.state.searchInput}
						reff={
							(ref) => { this.barRef = ref }
						}
					/>
					<ScrollView
						ref={
							(ref) => {
								this.scrollRef = ref
							}
						}
						showsVerticalScrollIndicator={false}
						scrollEnabled={this.state.allowScroll}
						keyboardShouldPersistTaps="always"
					>
						<View
							style={css.map_section}
						>
							<Text>MapHeight: {LAYOUT.MAP_HEIGHT}</Text>
							<SearchMap
								location={this.props.location}
								selectedResult={
									(this.props.search_results) ? (
										this.props.search_results[this.state.selectedResult]
									) : null
								}
								shuttle={this.props.shuttle_stops}
								vehicles={this.state.vehicles}
								polylines={polylines}
							/>
						</View>
						<View
							style={css.map_section}
						>
							<SearchResults
								results={this.props.search_results}
								onSelect={index => this.updateSelectedResult(index)}
							/>
						</View>
						<View
							style={css.map_section}
						>
							<SearchSuggest
								onPress={this.updateSearchSuggest}
							/>
							{(Array.isArray(this.props.search_history) && (this.props.search_history.length !== 0)) ? (
								<SearchHistoryCard
									pressHistory={this.updateSearch}
									removeHistory={this.props.removeHistory}
									data={this.props.search_history}
								/>
							) : (null)}
						</View>
						<View
							style={css.map_section}
						>
							<SearchShuttleMenu
								shuttle_routes={this.props.shuttle_routes}
								onToggle={this.toggleRoute}
								toggles={this.props.toggles}
							/>
						</View>
					</ScrollView>
					<SearchResultsBar
						visible={(this.state.showBar && this.props.search_results !== null)}
						onPress={this.gotoResults}
					/>
				</View>
			)
		} else {
			return null
		}
	}
}

const mapStateToProps = (state, props) => (
	{
		location: state.location.position,
		locationPermission: state.location.permission,
		toggles: state.shuttle.toggles,
		routes: state.shuttle.routes,
		shuttle_routes: state.shuttle.routes,
		shuttle_stops: state.shuttle.stops,
		vehicles: state.shuttle.vehicles,
		search_history: state.map.history,
		search_results: state.map.results,
	}
)

const mapDispatchToProps = (dispatch, ownProps) => (
	{
		clearSearch: () => {
			dispatch({ type: 'CLEAR_MAP_SEARCH' })
		},
		fetchSearch: (term, location) => {
			dispatch({ type: 'FETCH_MAP_SEARCH', term, location })
		},
		toggle: (route) => {
			dispatch({ type: 'UPDATE_TOGGLE_ROUTE', route })
		},
		removeHistory: (index) => {
			dispatch({ type: 'REMOVE_HISTORY', index })
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(Map)
