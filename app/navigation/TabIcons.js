import React, { PropTypes } from 'react';
import { Text, View } from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';
import css from '../styles/css'

const propTypes = {
	selected: PropTypes.bool,
	title: PropTypes.string,
};

const TabIcons = function(props) {

	var tabIconText,
		tabIconName;

	if (props.title === 'UC San Diego') {
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
		<View style={css.tabContainer}>
			<Icon style={[ css.tabIcon, props.selected ? css.campus_primary : null ]} name={tabIconName} size={28} />
			<Text style={[ css.tabText, props.selected ? css.campus_primary : null ]}>
				{tabIconText}
			</Text>
		</View>
	);
}

TabIcons.propTypes = propTypes;
export default TabIcons;