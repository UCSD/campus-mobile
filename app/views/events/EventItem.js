import React from 'react';
import { Actions } from 'react-native-router-flux';

import DataItem from '../common/DataItem';

const EventItem = ({ data, card }) => (
	<DataItem
		data={data}
		card={card}
		onPress={() => Actions.EventDetail({ data })}
	/>
);

export default EventItem;
