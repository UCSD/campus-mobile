import React from 'react';
import {
	View,
} from 'react-native';

import QuicklinksList from './QuicklinksList';

const css = require('../../styles/css');
const logger = require('../../util/logger');

const QuicklinksListView = ({ data }) => {
	logger.ga('View Loaded: Quicklinks List View');

	return (
		<View style={css.view_all_container}>
			<QuicklinksList
				data={data}
				scrollEnabled={false}
			/>
		</View>
	);
};

export default QuicklinksListView;
