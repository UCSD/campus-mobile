import React, { PropTypes } from 'react';
import {
	TouchableOpacity,
	View,
	Text,
	StyleSheet,
	Dimensions,
	ListView,
	StatusBar,
	Platform
} from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';
import ElevatedView from 'react-native-elevated-view';

import css from '../../styles/css';
import { doPRM, getPRM, getMaxCardWidth } from '../../util/general';

const deviceHeight = Dimensions.get('window').height;
const statusBarHeight = Platform.select({
	ios: 0,
	android: StatusBar.currentHeight,
});
const resultsDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const SearchResultsCard = ({ results, onSelect }) => (
	<View>
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
						null
					)
				}
			</View>
		</ElevatedView>
	</View>
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
			{
				(data.distanceMilesStr) ? (
					<Text style={css.destinationcard_marker_dist_label}>{data.distanceMilesStr}</Text>
				) : (null)
			}
		</View>
	</TouchableOpacity>
);

const navHeight = Platform.select({
	ios: 58,
	android: 44
});

// device - (statusBar + navHeight + searchBar + listPadding + tabBar)
const listHeight = deviceHeight - (statusBarHeight + navHeight + 44 + 16 + 40);

const styles = StyleSheet.create({
	list_container: { width: getMaxCardWidth(), maxHeight: listHeight, },
	card_main: { top: 44 + 6, backgroundColor: '#FFFFFF', margin: 6, alignItems: 'flex-start', justifyContent: 'center', },
	touch: { backgroundColor: '#FFF' },
	list_row: { flexDirection: 'row', paddingVertical: 14, borderBottomWidth: 1, borderBottomColor: '#EEE', overflow: 'hidden', paddingLeft: 8, paddingRight: 8 },
});

export default SearchResultsCard;
