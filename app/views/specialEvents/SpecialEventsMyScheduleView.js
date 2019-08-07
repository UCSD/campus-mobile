import React from 'react'
import { View } from 'react-native'
import css from '../../styles/css'
import SpecialEventsListView from './SpecialEventsListView'

const SpecialEventsMyScheduleView = () => (
	<View style={css.main_full}>
		<SpecialEventsListView
			scrollEnabled={true}
			personal={true}
		/>
	</View>
)

export default SpecialEventsMyScheduleView
