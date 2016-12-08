import React, { PropTypes } from 'react';
import { TextInput, View } from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';

const css = require('../../styles/css');
const general = require('../../util/general');
const PRM = general.getPRM();

const SearchBar = ({ placeholder, update, style }) => (
	<View style={[css.map_searchbar_container, style]}>
		<TextInput
			placeholder={placeholder}
			autoCorrect={false}
			onSubmitEditing={(event) => update(event.nativeEvent.text)}
			blurOnSubmit={true}
			returnKeyType="search"
			clearButtonMode={'while-editing'}
			selectTextOnFocus={true}
			style={css.map_searchbar_input}
			underlineColorAndroid={'rgba(0,0,0,0)'}
		/>
		<Icon
			style={css.map_searchbar_icon}
			name="search"
			size={general.round(24 * PRM)}
			color={'rgba(0,0,0,.5)'}
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

export default SearchBar;
