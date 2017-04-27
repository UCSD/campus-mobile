import React from 'react';
import { View } from 'react-native';

import css from '../../styles/css';
import ConferenceListView from './ConferenceListView';

const ConferenceFullScheduleView = ({ schedule, saved, add, remove }) => (
	<View
		style={css.main_container}
	>
		<ConferenceListView
			scrollEnabled={true}
			personal={false}
		/>
	</View>
);

export default ConferenceFullScheduleView;
