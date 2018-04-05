import React from 'react'
import { View } from 'react-native'

const ColoredDot = ({ size, style, color }) => (
	<View style={style}>
		<View
			style={{
				width: size, height: size, borderRadius: size / 2, backgroundColor: color, zIndex: 2
			}}
		/>
	</View>
)

export default ColoredDot
