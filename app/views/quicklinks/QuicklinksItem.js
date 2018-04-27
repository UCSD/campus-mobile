import React from 'react'
import { View, Text, Image } from 'react-native'
import Icon from 'react-native-vector-icons/FontAwesome'

import css from '../../styles/css'
import Touchable from '../common/Touchable'
import { openURL } from '../../util/general'

const QuicklinksItem = ({ data }) => (
	<View style={css.links_row_container}>
		{(data.name && data.url && data.icon) ? (
			<Touchable onPress={() => openURL(data.url)}>
				<View style={css.links_row}>
					{data.icon.indexOf('fontawesome:') === 0 ? (
						<Icon
							name={data.icon.replace('fontawesome:','')}
							size={26}
							style={css.links_icon_fa}
						/>
					) : (
						<Image style={css.links_icon} source={{ uri: data.icon }} />
					)}
					<Text style={css.links_name}>{data.name}</Text>
					<Icon
						name="chevron-right"
						size={20}
						style={css.links_arrow_icon}
					/>
				</View>
			</Touchable>
		) : (null)}
	</View>
)

export default QuicklinksItem
