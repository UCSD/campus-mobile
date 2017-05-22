import React from 'react';

import { Actions } from 'react-native-router-flux';

import DataItem from '../common/DataItem';

const NewsItem = ({ data, card }) => (
	<DataItem
		data={data}
		card={card}
		onPress={() => Actions.NewsDetail({ data })}
	/>
);

export default NewsItem;
