import React, { PropTypes } from 'react';
import {
	View,
	StyleSheet,
	Dimensions,
	Text,
	ListView,
	TouchableOpacity
} from 'react-native';

import ElevatedView from 'react-native-elevated-view';
import Icon from 'react-native-vector-icons/FontAwesome';
import { getPRM, getMaxCardWidth } from '../../util/general';

const PRM = getPRM();
const deviceHeight = Dimensions.get('window').height;

const history = ['physics', 'wlh', 'geisel', 'solis', 'peterson'];
const historyDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const SearchHistoryCard = ({ data, pressHistory }) => (
	<ElevatedView
		style={styles.card_main}
		elevation={2}
	>
		<View style={styles.list_container}>
			<SearchHistoryList
				historyData={historyDataSource.cloneWithRows(data)}
				pressHistory={pressHistory}
			/>
		</View>
	</ElevatedView>
);

const SearchHistoryList = ({ historyData, pressHistory }) => (
	<ListView
		showsVerticalScrollIndicator={false}
		dataSource={historyData}
		renderRow={
			(row, sectionID, rowID) =>
				<SearchHistoryItem
					data={row}
					pressHistory={pressHistory}
				/>
		}
	/>
);

const SearchHistoryItem = ({ data, pressHistory }) => (
	<TouchableOpacity
		underlayColor={'rgba(200,200,200,.1)'}
		onPress={() => {
			pressHistory(data);
		}}
	>
		<View style={styles.list_row}>
			<View
				style={styles.icon_container}
			>
				<Icon
					name="history"
					size={Math.round(24 * PRM)}
					color={'rgba(0,0,0,.5)'}
				/>
			</View>
			<View
				style={styles.text_container}
			>
				<Text>{data}</Text>
			</View>
		</View>
	</TouchableOpacity>
);

SearchHistoryCard.propTypes = {

};

SearchHistoryCard.defaultProps = {

};

const styles = StyleSheet.create({
	list_container: { width: getMaxCardWidth(), padding: 8, maxHeight: Math.round(deviceHeight / 2) },
	card_main: { top: Math.round(44 * getPRM()) + 6, backgroundColor: '#FFFFFF', margin: 6, alignItems: 'flex-start', justifyContent: 'center',  },
	list_row: { flex: 1, flexDirection: 'row', paddingVertical: 14, borderBottomWidth: 1, borderBottomColor: '#EEE', overflow: 'hidden' },
	icon_container: { alignItems: 'center', flex: 0.1 },
	text_container: { flex: 0.9 }
});

export default SearchHistoryCard;
