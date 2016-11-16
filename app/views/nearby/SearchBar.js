import React, { PropTypes } from 'react';
import { TextInput } from 'react-native';

const SearchBar = ({ placeholder, update }) => (
	<TextInput
		placeholder={placeholder}
		autoCorrect={false}
		onSubmitEditing={(event) => update(event.nativeEvent.text)}
		clearButtonMode={'while-editing'}
		selectTextOnFocus={true}
		style={{ height: 50 }}
	/>
);

SearchBar.propTypes = {
	placeholder: PropTypes.string,
};

SearchBar.defaultProps = {
	placeholder: 'Search...'
};

export default SearchBar;
