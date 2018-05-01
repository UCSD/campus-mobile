import React from 'react'
import { View, Text } from 'react-native'
import Icon from 'react-native-vector-icons/Ionicons'

import Card from '../common/Card'
import SafeImage from './SafeImage'
import Touchable from '../common/Touchable'
import css from '../../styles/css'

const BannerCard = ({ title, image, onPress, onClose }) => (
	<Card>
		<Touchable
			onPress={() => onClose()}
			style={css.bc_closeContainer}
		>
			<Text style={css.bc_closeText}>Close</Text>
			<Icon
				size={13}
				name="md-close-circle"
				style={css.bc_closeIcon}
			/>
		</Touchable>
		<Touchable
			onPress={() => onPress()}
		>
			{image ? (
				<SafeImage
					source={{ uri: image }}
					style={css.bc_image}
				/>
			) : (
				<Text style={css.bc_cardTitle}>{title}</Text>
			)}
			<View style={css.bc_more}>
				<Text style={css.bc_more_label}>See Full Schedule</Text>
			</View>
		</Touchable>
	</Card>
)

export default BannerCard
