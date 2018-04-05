import React from 'react';
import PropTypes from 'prop-types';
import { View, StyleSheet } from 'react-native';
import DataListView from './DataListView';
import logger from '../../util/logger';
import css from '../../styles/css';
import {
	COLOR_LGREY,
	COLOR_MGREY
} from '../../styles/ColorConstants';

/**
 * @param  {String} title Nav header
 * @param  {Object[]} data
 * @param  {String} item String name of row item
 * @return {JSX}
 */
const DataListViewAll = ({ navigation }) => {
	const { params } = navigation.state;
	const { title, data, item, card } = params;
	logger.ga('View Loaded: ' + title + ' ListView');


	return (
		<DataListView
			style={(card) ? (styles.cardList) : (styles.fullList)}
			data={data}
			scrollEnabled={true}
			item={item}
			card={card}
		/>
	);
};

DataListViewAll.propTypes = {
	title: PropTypes.string,
	data: PropTypes.array.isRequired,
	item: PropTypes.string.isRequired
};

const styles = StyleSheet.create({
	fullList: { padding: 8, borderWidth: 2, borderColor: 'orange' },
	cardList: { backgroundColor: 'green', paddingBottom: 100 },
});

export default DataListViewAll;
