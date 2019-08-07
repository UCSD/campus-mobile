import React from 'react'
import { Text } from 'react-native'
import { withNavigation } from 'react-navigation'

import css from '../../styles/css'
import Touchable from '../common/Touchable'

const SurfButton = ({ navigation })  => (
	<Touchable
		style={css.surf_touchable}
		onPress={() => { navigation.navigate('SurfReport') }}
	>
		<Text style={css.surf_text}>Surf Report</Text>
	</Touchable>
)

export default withNavigation(SurfButton)
