import React from 'react'
import { View, ScrollView } from 'react-native'
import SafeImage from '../common/SafeImage'
import css from '../../styles/css'

const DiningImages = ({ images }) => (
	<View>
		{images ? (
			<ScrollView
				style={css.dd_images_scrollview}
				directionalLockEnabled={false}
				horizontal={true}
			>
				{images.map((object, i) => (
					<SafeImage
						key={object.small}
						style={css.dd_images_image}
						resizeMode="cover"
						source={{ uri: object.small }}
					/>
				))}
			</ScrollView>
		) : null }
	</View>
)

export default DiningImages
