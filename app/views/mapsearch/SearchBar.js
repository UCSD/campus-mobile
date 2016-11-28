import React, { PropTypes } from 'react';
import { TextInput, View } from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';

const css = require('../../styles/css');

const SearchBar = ({ placeholder, update, style }) => (
	<View style={[css.map_searchbar_container, style]}>
		<TextInput
			placeholder={placeholder}
			autoCorrect={false}
			onEndEditing={(event) => update(event.nativeEvent.text)}
			onSubmitEditing={(event) => update(event.nativeEvent.text)}
			clearButtonMode={'while-editing'}
			selectTextOnFocus={true}
			style={css.map_searchbar_input}
			underlineColorAndroid={'rgba(0,0,0,0)'}
		/>
		<Icon
			style={css.map_searchbar_icon}
			name='search'
			size={20}
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
