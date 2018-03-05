import React from 'react';
import PropTypes from 'prop-types';
import {
	View,
	StyleSheet,
	Dimensions,
	Text,
	ListView,
	TouchableOpacity
} from 'react-native';

import ElevatedView from 'react-native-elevated-view';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { getPRM, getMaxCardWidth } from '../../util/general';
import { COLOR_MGREY } from '../../styles/ColorConstants';

const PRM = getPRM();
const deviceHeight = Dimensions.get('window').height;

const historyDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const SearchHistoryCard = ({ data, pressHistory, removeHistory }) => (
	<ElevatedView
		style={styles.card_main}
		elevation={2}
	>
		<View style={styles.list_container}>
			<SearchHistoryList
				historyData={historyDataSource.cloneWithRows(data)}
				pressHistory={pressHistory}
				removeHistory={removeHistory}
			/>
		</View>
	</ElevatedView>
);

const SearchHistoryList = ({ historyData, pressHistory, removeHistory }) => (
	<ListView
		showsVerticalScrollIndicator={false}
		dataSource={historyData}
		keyboardShouldPersistTaps="always"
		renderRow={
			(row, sectionID, rowID) =>
				<SearchHistoryItem
					data={row}
					index={rowID}
					pressHistory={pressHistory}
					removeHistory={removeHistory}
				/>
		}
	/>
);

const SearchHistoryItem = ({ data, index, pressHistory, removeHistory }) => (
	<TouchableOpacity
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
			<TouchableOpacity
				onPress={() => {
					removeHistory(index);
				}}
				style={styles.icon_container}
			>
				<Icon
					name="cancel"
					size={Math.round(24 * PRM)}
					color={'rgba(0,0,0,.5)'}
				/>
			</TouchableOpacity>
		</View>
	</TouchableOpacity>
);

SearchHistoryCard.propTypes = {

};

SearchHistoryCard.defaultProps = {

};

const styles = StyleSheet.create({
	list_container: { width: getMaxCardWidth(), padding: 8, maxHeight: Math.round(deviceHeight / 2) },
	card_main: { top: 44 + 6, backgroundColor: 'white', margin: 6, alignItems: 'flex-start', justifyContent: 'center',  },
	list_row: { flex: 1, flexDirection: 'row', paddingVertical: 14, borderBottomWidth: 1, borderBottomColor: COLOR_MGREY, overflow: 'hidden' },
	icon_container: { alignItems: 'center', width: 30 },
	text_container: { flex: 1 }
});

export default SearchHistoryCard;
