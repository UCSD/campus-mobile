import React from 'react';
import {
	View
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
const DataListViewAll = ({ title, data, item }) => {
	logger.ga('View Loaded: ' + title + ' ListView');

	return (
		<View style={css.main_container}>
			<DataListView
				style={css.welcome_listview}
				data={data}
				scrollEnabled={true}
				item={item}
				card={true}
			/>
		</View>
	);
};

export default DataListViewAll;
