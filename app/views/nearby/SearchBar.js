import React, { PropTypes } from 'react';
import { TextInput } from 'react-native';

const SearchBar = ({ placeholder, update }) => (
	<TextInput
		placeholder={placeholder}
		autoCorrect={false}
		onSubmitEditing={(event) => update(event.nativeEvent.text)}
	/>
);

SearchBar.propTypes = {
	placeholder: PropTypes.string,
};

SearchBar.defaultProps = {
	placeholder: 'Search...'
};

export default SearchBar;
