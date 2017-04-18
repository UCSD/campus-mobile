import React, { PropTypes } from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	StyleSheet,
	ActivityIndicator
} from 'react-native';

import { Actions } from 'react-native-router-flux';

import DataListView from './DataListView';
import Card from '../card/Card';
import { getCampusPrimary, getMaxCardWidth } from '../../util/general';

/**
 * @param  {String} title Card header
 * @param {Object[]} data contains data for row items
 * @param {String} item String name for row item, passing string here instead of actual component cuz of Actions
 * @param {Number} rows number of rows to display on card
 * @param {Function} cardSort array sorting function
 * @return {JSX} Generic component for list type cards
 */
const DataListCard = ({ title, data, item, rows, cardSort }) => {
	let sortedData = data;
	if (cardSort && sortedData) {
		sortedData = sortedData.slice().sort(cardSort);
	}

	return (
		<Card id={title} title={title}>
			<View style={styles.list}>
				{data ? (
					<View>
						<DataListView
							data={sortedData}
							rows={rows}
							scrollEnabled={false}
							item={item}
							card={false}
						/>
						<TouchableHighlight
							underlayColor={'rgba(200,200,200,.1)'}
							onPress={() => (
								Actions.DataListViewAll({ title, data, item }) // Actions doesn't like being passed JSX
							)}
						>
							<View style={styles.more}>
								<Text style={styles.more_label}>View All</Text>
							</View>
						</TouchableHighlight>
					</View>
				) : (
					<View style={[styles.cardcenter, styles.wc_loading_height]}>
						<ActivityIndicator size="large" />
					</View>
				)}
			</View>
		</Card>
	);
};

DataListCard.propTypes = {
	title: PropTypes.string.isRequired,
	data: PropTypes.array,
	item: PropTypes.string.isRequired,
	rows: PropTypes.number,
	cardSort: PropTypes.func,
};

DataListCard.defaultProps = {
	rows: 3
};

const styles = StyleSheet.create({
	list: { alignSelf: 'stretch', padding: 8 },
	content_load_err: { padding: 30, fontSize:16, alignSelf: 'center'  },
	more: { alignItems: 'center', justifyContent: 'center', paddingHorizontal: 4, paddingTop: 8, paddingBottom: 4 },
	more_label: { fontSize: 20, color: getCampusPrimary(), fontWeight: '300' },
	cardcenter: { alignItems: 'center', justifyContent: 'center', width: getMaxCardWidth() },
});

export default DataListCard;
