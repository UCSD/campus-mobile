import React, { PropTypes } from 'react';
import { View, Text } from 'react-native';
import FontAwesome from 'react-native-vector-icons/FontAwesome';
import Entypo from 'react-native-vector-icons/Entypo';

import AppSettings from '../AppSettings';
import css from '../styles/css';

const propTypes = {
	selected: PropTypes.bool,
	title: PropTypes.string,
};

const TabIcons = function (props) {
	let tabIconPack,
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
		tabIconName = 'new-message';
		tabIconText = 'Feedback';
	} else if (props.title === 'Settings') {
		tabIconPack = 'FontAwesome';
		tabIconName = 'gear';
		tabIconText = 'Settings';
	} else if (props.title === 'Full') {
		return (
			<Text style={props.selected ? css.CAMPUS_PRIMARY : { opacity: 0.5 }}>
				Full
			</Text>
		);
	} else if (props.title === 'Mine') {
		return (
			<Text style={props.selected ? css.CAMPUS_PRIMARY : { opacity: 0.5 }}>
				Mine
			</Text>
		);
	}

	return (
		<View style={[css.tabContainer, props.selected ? css.tabContainerBottom : null]}>
			{tabIconPack === 'FontAwesome' ? (<FontAwesome style={[css.tabIcon, props.selected ? css.CAMPUS_PRIMARY : null]} name={tabIconName} size={24} />) : null }
			{tabIconPack === 'Entypo' ? (<Entypo style={[css.tabIcon, props.selected ? css.CAMPUS_PRIMARY : null]} name={tabIconName} size={24} />) : null }
		</View>
	);
};

TabIcons.propTypes = propTypes;
export default TabIcons;
