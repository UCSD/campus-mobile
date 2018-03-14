import React from 'react';
import PropTypes from 'prop-types';
import { View, Text } from 'react-native';
import Entypo from 'react-native-vector-icons/Entypo';

import AppSettings from '../AppSettings';
import css from '../styles/css';
import { COLOR_PRIMARY } from '../styles/ColorConstants';

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
	} else if (props.title === 'User Settings') {
		tabIconPack = 'Entypo';
		tabIconName = 'user';
		tabIconText = 'Settings';
	}

	return (
		<View style={[css.tabContainer, props.focused ? css.tabContainerBottom : null]}>
			{tabIconPack === 'Entypo' && tabIconName !== 'user' ? (
				<Entypo
					style={[css.tabIcon, props.focused ? { color: COLOR_PRIMARY } : null]}
					name={tabIconName}
					size={24}
				/>
			) : null }
			{tabIconPack === 'Entypo' && tabIconName === 'user' ? (
				<View
					style={[css.tabIconUserOutline, props.focused ? { borderColor: COLOR_PRIMARY } : null]}
				>
					<Entypo
						style={[css.tabIconUser, props.focused ? { backgroundColor: COLOR_PRIMARY } : null]}
						name={tabIconName}
						size={24}
					/>
				</View>
			) : null }
		</View>
	);
};

TabIcons.propTypes = propTypes;
export default TabIcons;
