import {
	Dimensions,
	StatusBar,
} from 'react-native';
import {
	platformAndroid,
	deviceIphoneX
} from '../util/general';

const WINDOW_WIDTH = Dimensions.get('window').width,
	WINDOW_HEIGHT = Dimensions.get('window').height,
	MAX_CARD_WIDTH = WINDOW_WIDTH - 12,
	NAVIGATOR_IOS_HEIGHT = deviceIphoneX() ? 78 : 58,
	NAVIGATOR_ANDROID_HEIGHT = 44,
	NAVIGATOR_HEIGHT = platformAndroid() ? NAVIGATOR_ANDROID_HEIGHT : NAVIGATOR_IOS_HEIGHT,
	NAVIGATOR_LOGO_IOS_MARGIN = deviceIphoneX() ? 42 : 26,
	NAVIGATOR_LOGO_ANDROID_MARGIN = 12,
	STATUS_BAR_ANDROID_HEIGHT = platformAndroid() ? StatusBar.currentHeight : 0,
	TAB_BAR_HEIGHT = deviceIphoneX() ? 60 : 40,
	IOS_MARGIN_TOP = NAVIGATOR_IOS_HEIGHT,
	IOS_MARGIN_BOTTOM = TAB_BAR_HEIGHT,
	ANDROID_MARGIN_TOP = NAVIGATOR_ANDROID_HEIGHT + TAB_BAR_HEIGHT,
	ANDROID_MARGIN_BOTTOM = 0,
	MARGIN_TOP = platformAndroid() ? ANDROID_MARGIN_TOP : IOS_MARGIN_TOP,
	MARGIN_BOTTOM = platformAndroid() ? ANDROID_MARGIN_BOTTOM : IOS_MARGIN_BOTTOM;

module.exports = {

	/* LAYOUT CONSTANTS */
	WINDOW_WIDTH,
	WINDOW_HEIGHT,
	MAX_CARD_WIDTH,
	NAVIGATOR_IOS_HEIGHT,
	NAVIGATOR_ANDROID_HEIGHT,
	NAVIGATOR_HEIGHT,
	NAVIGATOR_LOGO_IOS_MARGIN,
	NAVIGATOR_LOGO_ANDROID_MARGIN,
	STATUS_BAR_ANDROID_HEIGHT,
	TAB_BAR_HEIGHT,
	IOS_MARGIN_TOP,
	IOS_MARGIN_BOTTOM,
	ANDROID_MARGIN_TOP,
	ANDROID_MARGIN_BOTTOM,
	MARGIN_TOP,
	MARGIN_BOTTOM,
};
