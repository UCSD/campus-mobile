import React from 'react';
import { View } from 'react-native';

import css from '../../styles/css';
import SpecialEventsListView from './SpecialEventsListView';

const SpecialEventsFullScheduleView = () => (
	<View
		style={[css.main_container, css.whitebg]}
	>
		<SpecialEventsListView
			scrollEnabled={true}
			personal={false}
		/>
	</View>
);

export default SpecialEventsFullScheduleView;
