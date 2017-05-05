import React from 'react';
import { View } from 'react-native';

import css from '../../styles/css';
import ConferenceListView from './ConferenceListView';

const ConferenceFullScheduleView = () => (
	<View
		style={[css.main_container, css.whitebg]}
	>
		<ConferenceListView
			scrollEnabled={true}
			personal={false}
		/>
	</View>
);

export default ConferenceFullScheduleView;
