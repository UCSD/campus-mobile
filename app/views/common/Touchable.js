import React from 'react';
import { Text, TouchableOpacity, TouchableNativeFeedback } from 'react-native';
import { platformAndroid } from '../../util/general';

class Touchable extends React.Component {
	constructor(props) {
		super(props);
	}
	
	render() {
		if (this.props.onPress && this.props.children) {
			if (platformAndroid()) {
				return (
					<TouchableNativeFeedback onPress={this.props.onPress} style={this.props.customStyle}>
						{this.props.children}
					</TouchableNativeFeedback>
				);
			} else {
				return (
					<TouchableOpacity onPress={this.props.onPress} activeOpacity={.6} style={this.props.customStyle}>
						{this.props.children}
					</TouchableOpacity>
				);
			}
		} else {
			return null;
		}
	}
}

export default Touchable;