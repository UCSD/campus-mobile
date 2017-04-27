import React, { PropTypes } from 'react';
import {
	View,
	StyleSheet
} from 'react-native';

import DataListView from './DataListView';

import css from '../../styles/css';
import logger from '../../util/logger';

/**
 * @param  {String} title Nav header
 * @param  {Object[]} data
 * @param  {String} item String name of row item
 * @return {JSX}
 */
const DataListViewAll = ({ title, data, item, card }) => {
	logger.ga('View Loaded: ' + title + ' ListView');
	console.log('card: ' + card);
	return (
		<View style={[css.main_container, css.white_bg]}>
			<DataListView
				style={(card) ? (styles.list_card) : (styles.list)}
				data={data}
				scrollEnabled={true}
				item={item}
				card={card}
			/>
		</View>
	);
};

DataListViewAll.propTypes = {
	title: PropTypes.string,
	data: PropTypes.array.isRequired,
	item: PropTypes.string.isRequired
};

const styles = StyleSheet.create({
	list: { padding: 6, backgroundColor: '#F9F9F9' },
	list_card: { margin: 6 }
});

export default DataListViewAll;
