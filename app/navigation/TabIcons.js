import React, { PropTypes } from 'react';
import { Text, View } from 'react-native';
import FontAwesome from 'react-native-vector-icons/FontAwesome';
import MaterialIcons from 'react-native-vector-icons/MaterialIcons';
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

	if (props.title === AppSettings.APP_CAMPUS_NAME) {
		tabIconPack = 'FontAwesome';
		tabIconText = 'Home';
		tabIconName = 'home';
	} else if (props.title === 'Map') {
		tabIconPack = 'FontAwesome';
		tabIconText = 'Map';
		tabIconName = 'map-o';
	} else if (props.title === 'Feedback') {
		tabIconPack = 'MaterialIcons';
		tabIconName = 'contact-mail';
		tabIconText = 'Feedback';
	} else if (props.title === 'Settings') {
		tabIconPack = 'FontAwesome';
		tabIconName = 'gear';
		tabIconText = 'Settings';
	}

	return (
		<View style={[css.tabContainer, props.selected ? css.tabContainerBottom : null ]}>
			{tabIconPack === 'FontAwesome' ? (<FontAwesome style={[ css.tabIcon, props.selected ? css.campus_primary : null ]} name={tabIconName} size={32} />) : null }
			{tabIconPack === 'MaterialIcons' ? (<MaterialIcons style={[ css.tabIcon, props.selected ? css.campus_primary : null ]} name={tabIconName} size={32} />) : null }
		</View>
	);
}

TabIcons.propTypes = propTypes;
export default TabIcons;