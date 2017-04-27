import React from 'react';
import { View } from 'react-native';

import css from '../../styles/css';
import ConferenceListView from './ConferenceListView';

const ConferenceMyScheduleView = ({ schedule, saved, add, remove }) => (
	<View
		style={css.main_container}
	>
		<ConferenceListView
			scrollEnabled={true}
			personal={true}
		/>
	</View>
);

export default ConferenceMyScheduleView;
