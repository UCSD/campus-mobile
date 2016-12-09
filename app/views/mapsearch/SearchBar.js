import React, { PropTypes } from 'react';
import { TextInput, View, ActivityIndicator, StyleSheet } from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';
import { getPRM, getMaxCardWidth } from '../../util/general';

const css = require('../../styles/css');

const PRM = getPRM();

const SearchBar = ({ placeholder, update, loading, style }) => (
	<View style={[styles.map_searchbar_container, style]}>
		{(loading) ?
			(
				<ActivityIndicator
					style={styles.load}
					size="small"
				/>
			) :
			(
				<Icon
					style={styles.map_searchbar_icon}
					name="search"
					size={Math.round(24 * PRM)}
					color={'rgba(0,0,0,.5)'}
				/>
			)
		}
		<TextInput
			placeholder={placeholder}
			autoCorrect={false}
			onSubmitEditing={(event) => update(event.nativeEvent.text)}
			blurOnSubmit={true}
			returnKeyType="search"
			clearButtonMode={'while-editing'}
			selectTextOnFocus={true}
			style={styles.map_searchbar_input}
			underlineColorAndroid={'rgba(0,0,0,0)'}
		/>
	</View>
);

SearchBar.propTypes = {
	placeholder: PropTypes.string,
	update: React.PropTypes.func
};

SearchBar.defaultProps = {
	placeholder: 'Search...'
};

const styles = StyleSheet.create({
	map_searchbar_container: { width: getMaxCardWidth(), flexDirection: 'row' },
	map_searchbar_icon: { top: Math.round(9 * PRM), left: Math.round(8 * PRM) },
	load: { left: Math.round(8 * PRM) },
	map_searchbar_input: { flex: 0.9,  height: Math.round(44 * PRM), padding: Math.round(8 * PRM), paddingLeft: Math.round(40 * PRM), backgroundColor: 'rgba(0,0,0,0)', zIndex: 10, color: '#555', fontSize: Math.round(20 * PRM) },
});

export default SearchBar;
