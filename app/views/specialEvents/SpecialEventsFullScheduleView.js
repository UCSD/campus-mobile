import React from 'react';
import { View } from 'react-native';
import css from '../../styles/css';
import SpecialEventsListView from './SpecialEventsListView';

const SpecialEventsFullScheduleView = () => (
	<View
		style={css.main_full_lgrey}
	>
		<SpecialEventsListView
			scrollEnabled={true}
			personal={false}
		/>
	</View>
);

export default SpecialEventsFullScheduleView;
