import React from 'react';
import { withNavigation } from 'react-navigation';

import DataItem from '../common/DataItem';

const EventItem = ({ navigation, data, card }) => (
	<DataItem
		data={data}
		card={card}
		onPress={() => { navigation.navigate('EventDetail', { data }); }}
	/>
);

export default withNavigation(EventItem);
