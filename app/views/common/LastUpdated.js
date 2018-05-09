/* eslint object-curly-newline: 0 */
import React from 'react'
import { View, Text } from 'react-native'

import FAIcon from 'react-native-vector-icons/FontAwesome'
import css from '../../styles/css'

const LastUpdated = ({ message, error, style }) => (
	<View style={[css.card_last_updated, style]}>
		{ error === 'warn' ? (
			<FAIcon name="warning" style={[css.last_updated_err_icon, css.last_updated_err_icon_warn]} />
		) : null }
		{ error === 'error' ? (
			<FAIcon name="warning" style={[css.last_updated_err_icon, css.last_updated_err_icon_error]} />
		) : null }
		<Text style={css.card_last_updated_text}>
			{message}
		</Text>
	</View>
)

export default LastUpdated
