import React from 'react';
import PropTypes from 'prop-types';
import {
	View,
	StyleSheet
} from 'react-native';
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
	console.log('card: ' + card);
	return (
		<View style={css.main_full}>
			<DataListView
				style={(card) ? (styles.cardList) : (styles.list)}
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
	list: { padding: 6, backgroundColor: COLOR_LGREY },
	cardList: { margin: 6 }
});

export default DataListViewAll;
