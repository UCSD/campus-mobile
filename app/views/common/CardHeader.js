import React from 'react'
import { View, Text } from 'react-native'

import css from '../../styles/css'

const CardHeader = ({ id, title, menu, hideHeader }) => {
	if (!title || !id || !menu || hideHeader) {
		return null
	} else {
		return (
			<View style={css.ch_headerContainer}>
				<Text style={css.ch_titleText}>
					{title}
				</Text>
				<View style={css.ch_filler} />
				{menu}
			</View>
		)
	}
}

export default CardHeader
