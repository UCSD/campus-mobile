import React, { PropTypes } from 'react';
import { TextInput, View } from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';

const SearchBar = ({ placeholder, update, style }) => (
	<View style={[{ flex:1, flexDirection: 'row', alignItems: 'center' }, style]}>
		<TextInput
			placeholder={placeholder}
			autoCorrect={false}
			onEndEditing={(event) => update(event.nativeEvent.text)}
			onSubmitEditing={(event) => update(event.nativeEvent.text)}
			clearButtonMode={'while-editing'}
			selectTextOnFocus={true}
			style={{ height: 50, flex: 0.9 }}
			underlineColorAndroid={'rgba(0,0,0,0)'}
		/>
		<Icon
			style={{ flex: 0.1, padding: 8 }}
			name="search" size={25}
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
