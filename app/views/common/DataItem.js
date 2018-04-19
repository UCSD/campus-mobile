import React from 'react'
import PropTypes from 'prop-types'
import { View, Text } from 'react-native'

import Touchable from './Touchable'
import SafeImage from './SafeImage'
import css from '../../styles/css'

/**
 * Generic row item
 * @param  {Object} data
 * @param {Boolean} card Display using card style
 * @param {Function} onPress
 * @return {JSX}
 * @todo  Standardize and make this more generic/applicable?
 */
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

DataItem.propTypes = {
	data: PropTypes.object.isRequired,
	card: PropTypes.bool,
	onPress: PropTypes.func,
}

DataItem.defaultProps = {
	card: false
}

export default DataItem
