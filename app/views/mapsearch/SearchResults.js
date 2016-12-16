import React, { PropTypes } from 'react';
import { TouchableHighlight, View, Text, StyleSheet } from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';
import css from '../../styles/css';

const SearchResults = ({ results, onSelect }) => (
	<View>
		{results ?
			(
				results.map((result, index) => (
					<TouchableHighlight
						key={index}
						underlayColor={'rgba(200,200,200,.1)'}
						onPress={() => onSelect(index)}
						style={styles.touch}
					>
						<View style={css.destinationcard_marker_row}>
							<Icon name="map-marker" size={30} />
							<Text style={css.destinationcard_marker_label}>{result.title}</Text>
						</View>
					</TouchableHighlight>
				))
			) : (
				<Text style={styles.no_result}>
					No results found, please try a different search term.
				</Text>
			)
		}
	</View>
);

SearchResults.propTypes = {
	onSelect: PropTypes.func
};

SearchResults.defaultProps = {};

const styles = StyleSheet.create({
	touch: { backgroundColor: '#FFF' },
	no_result: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', padding: 6, marginTop: 0 },
});

export default SearchResults;
