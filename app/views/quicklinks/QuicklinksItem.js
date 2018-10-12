import React from 'react'
import { View, Text, Image } from 'react-native'
import FAIcon from 'react-native-vector-icons/FontAwesome'
import Ionicons from 'react-native-vector-icons/Ionicons'

import css from '../../styles/css'
import Touchable from '../common/Touchable'
import { openURL } from '../../util/general'

const QuicklinksItem = ({ data }) => {
	if (data.name && data.url && data.icon) {
		return (
			<Touchable onPress={() => openURL(data.url)}>
				<View style={css.links_row_container}>
					<View style={css.links_row}>
						{data.icon.indexOf('fontawesome:') === 0 ? (
							<FAIcon
								name={data.icon.replace('fontawesome:','')}
								size={21}
								style={css.links_icon_fa}
							/>
						) : (
							<Image style={css.links_icon} source={{ uri: data.icon }} />
						)}
						<Text style={css.links_name}>{data.name}</Text>
						<Ionicons name="ios-arrow-forward" size={28} style={css.pi_arrow} />
					</View>
				</View>
			</Touchable>
		)
	} else {
		return null
	}
}

export default QuicklinksItem
