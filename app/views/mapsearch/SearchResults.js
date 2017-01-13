import React, { PropTypes } from 'react';
import {
	TouchableOpacity,
	View,
	Text,
	StyleSheet,
	Dimensions,
	ListView
} from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';
import ElevatedView from 'react-native-elevated-view';

import css from '../../styles/css';
import { getPRM, getMaxCardWidth } from '../../util/general';

const deviceHeight = Dimensions.get('window').height;
const resultsDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const SearchResultsCard = ({ results, onSelect }) => (
	<ElevatedView
		style={styles.card_main}
		elevation={2}
	>
		<View style={styles.list_container}>
			{results ?
				(
					<SearchResultsList
						results={resultsDataSource.cloneWithRows(results)}
						onSelect={onSelect}
					/>
				) : (
					<Text style={styles.no_result}>
						No results found, please try a different search term.
					</Text>
				)
			}
		</View>
	</ElevatedView>
);

SearchResultsCard.propTypes = {
	onSelect: PropTypes.func
};

SearchResultsCard.defaultProps = {};

const SearchResultsList = ({ results, onSelect }) => (
	<ListView
		dataSource={results}
		renderRow={
			(row, sectionID, rowID) =>
				<SearchResultsItem
					data={row}
					index={rowID}
					onSelect={onSelect}
				/>
		}
	/>
);

const SearchResultsItem = ({ data, onSelect, index }) => (
	<TouchableOpacity
		key={index}
		underlayColor={'rgba(200,200,200,.1)'}
		onPress={() => onSelect(index)}
		style={styles.touch}
	>
		<View style={styles.list_row}>
			<Icon name="map-marker" size={30} />
			<Text style={css.destinationcard_marker_label}>{data.title}</Text>
		</View>
	</TouchableOpacity>
);

const styles = StyleSheet.create({
	list_container: { flex:1, width: getMaxCardWidth(), padding: 8 },
	card_main: { flex: 1, backgroundColor: '#FFFFFF', margin: 6, alignItems: 'flex-start', justifyContent: 'center', height: deviceHeight - (84 + (44 * getPRM())) },
	touch: { backgroundColor: '#FFF' },
	no_result: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', padding: 6, marginTop: 0 },
	list_row: { flex: 1, flexDirection: 'row', paddingVertical: 14, borderBottomWidth: 1, borderBottomColor: '#EEE', overflow: 'hidden' },
});

export default SearchResultsCard;
