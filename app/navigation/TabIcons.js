import React from 'react';
import PropTypes from 'prop-types';
import { View, Text } from 'react-native';
import Entypo from 'react-native-vector-icons/Entypo';

import AppSettings from '../AppSettings';
import css from '../styles/css';
import { COLOR_PRIMARY } from '../styles/ColorConstants';

const propTypes = {
	title: PropTypes.string.isRequired,
	focused: PropTypes.bool.isRequired,
};

const TabIcons = (props) => {
	let tabIconPack,
		tabIconText,
		tabIconName;

	if (props.title === 'Home') {
		tabIconPack = 'Entypo';
		tabIconName = 'home';
		tabIconText = 'Home';
	} else if (props.title === 'Map') {
		tabIconPack = 'Entypo';
		tabIconName = 'location';
		tabIconText = 'Map';
	} else if (props.title === 'Feedback') {
		tabIconPack = 'Entypo';
		tabIconName = 'new-message';
		tabIconText = 'Feedback';
	} else if (props.title === 'Preferences') {
		tabIconPack = 'Entypo';
		tabIconName = 'user';
		tabIconText = 'User Settings';
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
