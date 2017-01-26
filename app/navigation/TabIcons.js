import React, { PropTypes } from 'react';
import { Text, View } from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';
import AppSettings from '../AppSettings';
import general from '../util/general';
import css from '../styles/css'

const propTypes = {
	selected: PropTypes.bool,
	title: PropTypes.string,
};

const TabIcons = function(props) {

	var tabIconText,
		tabIconName;

	if (props.title === AppSettings.APP_CAMPUS_NAME) {
		tabIconText = 'Home';
		tabIconName = 'home';
	} else if (props.title === 'Map') {
		tabIconText = 'Map';
		tabIconName = 'globe';
	} else if (props.title === 'Settings') {
		tabIconName = 'gear';
		tabIconText = 'Settings';
	}

	return (
		<View style={[css.tabContainer, props.selected ? css.tabContainerBottom : null ]}>
			<Icon style={[ css.tabIcon, props.selected ? css.campus_primary : null ]} name={tabIconName} size={32} />
		</View>
	);
}

TabIcons.propTypes = propTypes;
export default TabIcons;