import { Dimensions, StatusBar } from 'react-native'
import { platformAndroid, deviceIphoneX } from '../util/general'

const WINDOW_WIDTH = Dimensions.get('window').width
const WINDOW_HEIGHT = Dimensions.get('window').height
const STATUS_BAR_HEIGHT = platformAndroid() ? StatusBar.currentHeight : 0
const NAVIGATOR_HEIGHT = 42
const TAB_BAR_HEIGHT = deviceIphoneX() ? 31 : NAVIGATOR_HEIGHT
const MAX_CARD_WIDTH = WINDOW_WIDTH - 12
const MAX_CONTENT_HEIGHT = WINDOW_HEIGHT - NAVIGATOR_HEIGHT
const MAP_HEIGHT = (WINDOW_HEIGHT) - (NAVIGATOR_HEIGHT + TAB_BAR_HEIGHT + STATUS_BAR_HEIGHT)

const LAYOUT = {
	WINDOW_WIDTH,
	WINDOW_HEIGHT,
	NAVIGATOR_HEIGHT,
	STATUS_BAR_HEIGHT,
	TAB_BAR_HEIGHT,
	MAX_CARD_WIDTH,
	MAX_CONTENT_HEIGHT,
	MAP_HEIGHT,
}

module.exports = LAYOUT