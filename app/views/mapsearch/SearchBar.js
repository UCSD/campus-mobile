import React, { PropTypes } from 'react';
import { TextInput, View, ActivityIndicator } from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';
import { getPRM, getMaxCardWidth } from '../../util/general';

const css = require('../../styles/css');

const PRM = getPRM();

const SearchBar = ({ placeholder, update, loading, style }) => (
	<View style={[css.map_searchbar_container, style]}>
		{loading ? (
			<ActivityIndicator style={css.map_searchbar_ai} size="small" />
		) : (
			<Icon
				style={css.map_searchbar_icon}
				name="search"
				size={Math.round(24 * PRM)}
				color={'rgba(0,0,0,.5)'}
			/>
		)}
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
