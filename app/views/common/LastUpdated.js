/* eslint object-curly-newline: 0 */
import React from 'react'
import { View, Text } from 'react-native'
import moment from 'moment'

import FAIcon from 'react-native-vector-icons/FontAwesome'
import css from '../../styles/css'

const LastUpdated = ({ lastUpdated, warning, error, style }) => {
	if (lastUpdated) {
		let warningComponent = null
		let messageText = `Last updated: ${moment(lastUpdated).fromNow()}`
		if (warning) {
			warningComponent = (
				<FAIcon name="warning" style={[css.last_updated_err_icon, css.last_updated_err_icon_warn]} />
			)
			messageText = warning
		}
		else if (error) {
			warningComponent = (
				<FAIcon name="warning" style={[css.last_updated_err_icon, css.last_updated_err_icon_error]} />
			)
			messageText = error
		}
		return (
			<View style={[css.card_last_updated, style]}>
				{warningComponent}
				<Text style={css.card_last_updated_text}>
					{messageText}
				</Text>
			</View>
		)
	} else {
		return null
	}
}

export default LastUpdated
