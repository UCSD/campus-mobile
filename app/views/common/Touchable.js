import React from 'react'
import { TouchableOpacity, TouchableNativeFeedback } from 'react-native'

const Touchable = ({ onPress, style, disabled, children }) => {
	if (onPress && children) {
		if (false) {
			return (
				<TouchableNativeFeedback disabled={disabled} onPress={onPress} style={style}>
					{children}
				</TouchableNativeFeedback>
			)
		} else {
			return (
				<TouchableOpacity disabled={disabled} onPress={onPress} activeOpacity={0.7} style={style}>
					{children}
				</TouchableOpacity>
			)
		}
	} else {
		return null
	}
}

export default Touchable
