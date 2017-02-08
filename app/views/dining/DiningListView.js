import React from 'react';
import {
	View,
} from 'react-native';

import DiningList from './DiningList';

const css = require('../../styles/css');
const logger = require('../../util/logger');

const DiningListView = ({ data }) => {
	logger.ga('View Mounted: Dining List View');

	return (
		<View style={css.view_all_container}>
			<DiningList data={data} />
		</View>
	);
};

export default DiningListView;
