import React from 'react'
import { View, Text } from 'react-native'
import Touchable from './Touchable'
import SafeImage from './SafeImage'
import css from '../../styles/css'

const DataItem = ({ data, card, onPress }) => (
	<Touchable
		onPress={() => onPress(data)}
		style={css.dataitem_touchableRow}
	>
		<Text style={css.dataitem_titleText}>{data.title}</Text>
		<View style={css.dataitem_listInfoContainer}>
			<View style={css.dataitem_descContainer}>
				{data.description ? (
					<Text
						style={css.dataitem_descText}
						numberOfLines={2}
					>
						{data.description.trim()}
					</Text>
				) : null }
				<Text style={css.dataitem_dateText}>{data.subtext}</Text>
			</View>
			<SafeImage style={css.dataitem_image} source={{ uri: data.image }} />
		</View>
	</Touchable>
)

export default DataItem
