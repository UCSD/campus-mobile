import React from 'react'
import { Text } from 'react-native'
import { withNavigation } from 'react-navigation'

import css from '../../styles/css'
import Touchable from '../common/Touchable'

const FullScheduleButton = ({ navigation }) => (
	<Touchable
		style={css.card_button_container}
		onPress={() => { navigation.navigate('FullSchedule') }}
	>
		<Text style={css.card_button_text}>View All</Text>
	</Touchable>
)

export default withNavigation(FullScheduleButton)
