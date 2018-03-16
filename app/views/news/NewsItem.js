import React from 'react';
import { withNavigation } from 'react-navigation';

import DataItem from '../common/DataItem';

const NewsItem = ({ navigation, data, card }) => (
	<DataItem
		data={data}
		card={card}
		onPress={() => { navigation.navigate('NewsDetail', { data }); }}
	/>
);

export default withNavigation(NewsItem);
