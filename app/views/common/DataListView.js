import React from 'react';
import PropTypes from 'prop-types';
import {
	FlatList,
} from 'react-native';

import EventItem from '../events/EventItem';
import NewsItem from '../news/NewsItem';
import DiningItem from '../dining/DiningItem';
import QuicklinksItem from '../quicklinks/QuicklinksItem';

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
	<FlatList
		style={style}
		scrollEnabled={scrollEnabled}
		data={(rows) ? (data.slice(0,rows)) : (data)}
		keyExtractor={(listItem, index) => {
			// We receieve all sorts of data here.
			// TODO: Mandate that if DataListView is used, an id is passed
			if (listItem.id) return listItem.id;
			else if (listItem.name) return listItem.name;
			else if (listItem.title) return listItem.title;
		}}
		renderItem={({ item: rowData }) => {
			// Add to switch statement as new Items are needed
			// Only reason this is a switch is cuz Actions from react-router-flux doesn't like being passed JSX
			// Should revisit to see if this can be simplified
			switch (item) {
			case 'EventItem': {
				return (<EventItem data={rowData} card={card} />);
			}
			case 'NewsItem': {
				return (<NewsItem data={rowData} card={card} />);
			}
			case 'DiningItem': {
				return (<DiningItem data={rowData} card={card} />);
			}
			case 'QuicklinksItem': {
				return (<QuicklinksItem data={rowData} card={card} />);
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
