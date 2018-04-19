import React from 'react'
import {
	Text,
	StyleSheet,
} from 'react-native'
import { withNavigation } from 'react-navigation'

import {
	COLOR_PRIMARY,
	COLOR_MGREY
} from '../../styles/ColorConstants'
import { MAX_CARD_WIDTH } from '../../styles/LayoutConstants'
import Touchable from '../common/Touchable'

const FullScheduleButton = ({ navigation }) => (
	<Touchable
		style={styles.touchable}
		onPress={() => { navigation.navigate('FullSchedule') }}
	>
		<Text style={styles.text}>View Full Schedule &raquo;</Text>
	</Touchable>
)

const styles = StyleSheet.create({
	touchable: { borderTopWidth: 1, borderTopColor: COLOR_MGREY, width: MAX_CARD_WIDTH },
	text: { fontSize: 20, fontWeight: '300', color: COLOR_PRIMARY, paddingHorizontal: 14, paddingVertical: 10,  },
})

export default withNavigation(FullScheduleButton)
