import React, { Component } from 'react';
import {
	View,
	StatusBar,
	Image,
} from 'react-native';
import { Scene, Router, Actions } from 'react-native-router-flux';
import { connect } from 'react-redux';

import AppSettings from './AppSettings';
import css from './styles/css';
import general from './util/general';

// PUSH
import PushNotificationContainer from './containers/pushNotificationContainer';

// VIEWS
import Home from './views/Home';
import SurfReport from './views/weather/SurfReport';
import ShuttleStop from './views/shuttle/ShuttleStop';
import DiningDetail from './views/dining/DiningDetail';
import DiningNutrition from './views/dining/DiningNutrition';
import EventDetail from './views/events/EventDetail';
import WebWrapper from './views/WebWrapper';
import NewsDetail from './views/news/NewsDetail';
import FeedbackView from './views/FeedbackView';
import PreferencesView from './views/preferences/PreferencesView';
import NearbyMapView from './views/mapsearch/NearbyMapView';
import TabIcons from './navigation/TabIcons';
import DataListViewAll from './views/common/DataListViewAll';
import SpecialEventsView from './views/specialEvents/SpecialEventsView';
import SpecialEventsDetailView from './views/specialEvents/SpecialEventsDetailView';
import ShuttleRoutesListView from './views/shuttle/ShuttleRoutesListView';
import ShuttleStopsListView from './views/shuttle/ShuttleStopsListView';
import ShuttleSavedListView from './views/shuttle/ShuttleSavedListView';

function mapStateToProps(state, props) {
	return {
		scene: state.routes.scene,
	};
}
const RouterWithRedux = connect()(Router);

class Main extends Component {
	constructor(props) {
		super(props);

		this.state = {
			hideTabs: false
		};
	}

	campusLogo() {
		return (<Image source={require('./assets/img/UCSanDiegoLogo-nav.png')} style={css.navCampusLogoTitle} />);
	}

	shouldComponentUpdate() {
		return false;
	}

	_exitHandler = () => {
		if (this.props.scene.sceneKey !== 'Home' && this.props.scene.sceneKey !== 'tabbar') {
			Actions.tab1();
			return true;
		} else {
			return false;
		}
	}

	render() {
		if (general.platformIOS()) {
			StatusBar.setBarStyle('light-content');
		} else if (general.platformAndroid()) {
			StatusBar.setBackgroundColor('#101d32', false);
		}

		return (
			<View style={css.flex}>
				<PushNotificationContainer />
				<RouterWithRedux
					navigationBarStyle={general.platformIOS() ? css.navIOS : css.navAndroid}
					titleStyle={general.platformIOS() ? css.navIOSTitle : css.navAndroidTitle}
					barButtonIconStyle={general.platformIOS() ? css.navIOSIconStyle : css.navAndroidIconStyle}
					backButtonTextStyle={general.platformIOS() ? css.navButtonTextIOS : css.navButtonTextAndroid}
					rightButtonTextStyle={general.platformIOS() ? css.navButtonTextIOS : css.navButtonTextAndroid}
					backTitle="Back"
					onExitApp={this._exitHandler}
				>
					<Scene key="root">
						<Scene
							key="tabbar"
							tabs hideOnChildTabs initial
							tabBarStyle={general.platformIOS() ? css.tabBarIOS : css.tabBarAndroid}
						>
							<Scene key="tab1" title={AppSettings.APP_NAME} initial icon={TabIcons}>
								<Scene key="Home" component={Home} renderTitle={() => this.campusLogo()} />
								<Scene key="SurfReport" component={SurfReport} title="Surf Report" hideTabBar />
								<Scene key="ShuttleStop" component={ShuttleStop} title="Shuttle" hideTabBar />
								<Scene key="DiningDetail" component={DiningDetail} title="Dining" hideTabBar />
								<Scene key="DiningNutrition" component={DiningNutrition} title="Nutrition" hideTabBar />
								<Scene key="EventDetail" component={EventDetail} title="Events" hideTabBar />
								<Scene key="WebWrapper" component={WebWrapper} hideTabBar />
								<Scene key="NewsDetail" component={NewsDetail} title="News" hideTabBar />
								<Scene key="DataListViewAll" component={DataListViewAll} hideTabBar />
								<Scene key="ShuttleRoutesListView" component={ShuttleRoutesListView} title="Choose Route" hideTabBar />
								<Scene key="ShuttleStopsListView" component={ShuttleStopsListView} title="Choose Stop" hideTabBar />
								<Scene key="ShuttleSavedListView" component={ShuttleSavedListView} title="Manage Stops" hideTabBar />
								<Scene key="SpecialEventsView" component={SpecialEventsView} title={(route) => route.specialEventsTitle} hideTabBar renderBackButton={(route) => route.backButton} renderRightButton={(route) => route.filterButton} />
								<Scene key="SpecialEventsDetailView" component={SpecialEventsDetailView} title={(route) => route.specialEventsTitle}  hideTabBar />
							</Scene>
							<Scene key="tab2" title="Map" component={NearbyMapView} icon={TabIcons} />
							<Scene key="tab3" title="Feedback" component={FeedbackView} icon={TabIcons} />
							<Scene key="tab4" title="User Settings" component={PreferencesView} icon={TabIcons} />
						</Scene>
					</Scene>
				</RouterWithRedux>
			</View>
		);
	}
}

export default connect(mapStateToProps)(Main);
