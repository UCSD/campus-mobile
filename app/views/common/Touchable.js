import React from 'react';
import { TouchableOpacity, TouchableNativeFeedback } from 'react-native';
import { platformAndroid } from '../../util/general';

const Touchable = ({ onPress, style, children }) => {
	if (onPress && children) {
		if (false) {
			return (
				<TouchableNativeFeedback onPress={onPress} style={style}>
					{children}
				</TouchableNativeFeedback>
			);
		} else {
			return (
				<TouchableOpacity onPress={onPress} activeOpacity={0.7} style={style}>
					{children}
				</TouchableOpacity>
			);
		}
	} else {
		return null;
	}
};

export default Touchable;
