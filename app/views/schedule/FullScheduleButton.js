import React from 'react'
import { Text } from 'react-native'
import { withNavigation } from 'react-navigation'

import css from '../../styles/css'
import Touchable from '../common/Touchable'

const FullScheduleButton = ({ navigation }) => (
	<Touchable
		style={css.schedule_full_button_touchable}
		onPress={() => { navigation.navigate('FullSchedule') }}
	>
		<Text style={css.schedule_full_button_text}>View Full Schedule</Text>
	</Touchable>
)

export default withNavigation(FullScheduleButton)
