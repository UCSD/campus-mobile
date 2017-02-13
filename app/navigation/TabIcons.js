import React, { PropTypes } from 'react';
import { Text, View } from 'react-native';
import FontAwesome from 'react-native-vector-icons/FontAwesome';
import Entypo from 'react-native-vector-icons/Entypo';

import AppSettings from '../AppSettings';
import general from '../util/general';
import css from '../styles/css'

const propTypes = {
	selected: PropTypes.bool,
	title: PropTypes.string,
};

const TabIcons = function(props) {

	var tabIconPack,
		tabIconText,
		tabIconName;

	if (props.title === AppSettings.APP_NAME) {
		tabIconPack = 'Entypo';
		tabIconText = 'Home';
		tabIconName = 'home';
	} else if (props.title === 'Map') {
		tabIconPack = 'Entypo';
		tabIconText = 'Map';
		tabIconName = 'location';
	} else if (props.title === 'Feedback') {
		tabIconPack = 'Entypo';
		tabIconName = 'chat';
		tabIconText = 'Feedback';
	} else if (props.title === 'Settings') {
		tabIconPack = 'FontAwesome';
		tabIconName = 'gear';
		tabIconText = 'Settings';
	}

	return (
		<View style={[css.tabContainer, props.selected ? css.tabContainerBottom : null ]}>
			{tabIconPack === 'FontAwesome' ? (<FontAwesome style={[ css.tabIcon, props.selected ? css.campus_primary : null ]} name={tabIconName} size={24} />) : null }
			{tabIconPack === 'Entypo' ? (<Entypo style={[ css.tabIcon, props.selected ? css.campus_primary : null ]} name={tabIconName} size={24} />) : null }
		</View>
	);
}

TabIcons.propTypes = propTypes;
export default TabIcons;