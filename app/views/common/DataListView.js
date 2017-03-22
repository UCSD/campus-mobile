import React, { PropTypes } from 'react';
import {
	ListView,
	StyleSheet,
} from 'react-native';

import EventItem from '../events/EventItem';
import NewsItem from '../news/NewsItem';
import DiningItem from '../dining/DiningItem';
import QuicklinksItem from '../quicklinks/QuicklinksItem';

const dataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

/**
 * Generic listview used by DataListCard
 * @param  {StyleSheet} style
 * @param {Object[]} data
 * @param {Number} rows Max number of rows
 * @param {Boolean} scrollEnabled
 * @param {String} item String name of row item
 * @param {Boolean} card Display rows with card styling (if available);
 * @return {JSX}
 * @todo Extract Items to a constants file or helper function
 */
const DataListView = ({ style, data, rows, scrollEnabled, item, card }) => (
	<ListView
		style={style}
		scrollEnabled={scrollEnabled}
		dataSource={dataSource.cloneWithRows((rows) ? (data.slice(0,rows)) : (data))}
		renderRow={(row) => {
			// Add to switch statement as new Items are needed
			// Only reason this is a switch is cuz Actions from react-router-flux doesn't like being passed JSX
			// Should revisit to see if this can be simplified
			switch (item) {
			case 'EventItem': {
				return (<EventItem data={row} card={card} />);
			}
			case 'NewsItem': {
				return (<NewsItem data={row} card={card} />);
			}
			case 'DiningItem': {
				return (<DiningItem data={row} card={card} />);
			}
			case 'QuicklinksItem': {
				return (<QuicklinksItem data={row} card={card} />);
			}
			default: {
				return null;
			}
			}
		}}
	/>
);

DataListView.propTypes = {
	style: PropTypes.number, // Stylesheet is a number for some reason?
	data: PropTypes.array.isRequired,
	rows: PropTypes.number,
	scrollEnabled: PropTypes.bool,
	item: PropTypes.string.isRequired,
	card: PropTypes.bool,
};

DataListView.defaultProps = {
	scrollEnabled: false,
	card: false
};

export default DataListView;
