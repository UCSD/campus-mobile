import React, { PropTypes } from 'react';
import {
	TextInput,
	View,
	ActivityIndicator,
	StyleSheet,
	Dimensions,
	TouchableHighlight,
	TouchableOpacity
} from 'react-native';

import ElevatedView from 'react-native-elevated-view';
import Icon from 'react-native-vector-icons/FontAwesome';
import { getPRM, getMaxCardWidth } from '../../util/general';

const css = require('../../styles/css');

const PRM = getPRM();
const windowWidth = Dimensions.get('window').width;

const SearchBar = ({ reff, placeholder, update, iconStatus, style, onFocus, pressIcon, searchInput }) => (
	<ElevatedView
		style={[styles.map_searchbar_container, style]}
		elevation={2} // zIndex style and elevation has to match
	>
		<TouchableOpacity
			style={styles.icon_container}
			onPress={(event) => pressIcon()}
		>
			<SearchIcon iconStatus={iconStatus} />
		</TouchableOpacity>
		<TextInput
			ref={reff}
			placeholder={placeholder}
			autoCorrect={false}
			onSubmitEditing={(event) => update(event.nativeEvent.text.trim())}
			blurOnSubmit={true}
			returnKeyType="search"
			clearButtonMode={'while-editing'}
			selectTextOnFocus={true}
			style={styles.map_searchbar_input}
			underlineColorAndroid={'rgba(0,0,0,0)'}
			onFocus={(event) => onFocus()}
			defaultValue={searchInput}
		/>
	</ElevatedView>
);

const SearchIcon = ({ iconStatus }) => {
	switch (iconStatus) {
	case 'load':
		return (
			<ActivityIndicator
				size="small"
			/>
		);
	case 'search':
		return (
			<Icon
				name="search"
				size={Math.round(24 * PRM)}
				color={'rgba(0,0,0,.5)'}
			/>
		);
	case 'menu':
		return (
			<Icon
				name="bars"
				size={Math.round(24 * PRM)}
				color={'rgba(0,0,0,.5)'}
			/>
		);
	case 'back':
		return (
			<Icon
				name="arrow-left"
				size={Math.round(24 * PRM)}
				color={'rgba(0,0,0,.5)'}
			/>
		);
	}
};

SearchBar.propTypes = {
	placeholder: PropTypes.string,
	update: React.PropTypes.func,
	searchInput: PropTypes.string
};

SearchBar.defaultProps = {
	placeholder: 'Search here',
	searchInput: ''
};

const styles = StyleSheet.create({
	map_searchbar_container: { zIndex: 2, margin: 6, flexDirection: 'row', position: 'absolute', width: windowWidth - 12, height: Math.round(44 * PRM), borderWidth: 0, backgroundColor: 'white', },
	map_searchbar_input: { flex: 1, height: Math.round(44 * PRM), padding: Math.round(8 * PRM), color: '#555', fontSize: Math.round(20 * PRM) },
	//map_searchbar_icon: { position: 'absolute', top: Math.round(9 * PRM), left: Math.round(8 * PRM) },
	map_searchbar_icon: { top: Math.round(9 * PRM), left: Math.round(8 * PRM) },
	map_searchbar_ai: { position: 'absolute', top: Math.round(12 * PRM), left: Math.round(8 * PRM) },
	icon_container: { height: Math.round(44 * PRM), justifyContent: 'center', alignSelf: 'center', margin: Math.round(8 * PRM), }
});

export default SearchBar;
