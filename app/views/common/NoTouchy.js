import React, { Component } from 'react';
import {
	View,
	PanResponder
} from 'react-native';

// Component that will not pass touch to other components
export default class NoTouchy extends Component {
	componentWillMount() {
		this._panResponder = PanResponder.create({
			onStartShouldSetPanResponder: (evt, gestureState) => true,
			onStartShouldSetPanResponderCapture: (evt, gestureState) => true,
			onMoveShouldSetPanResponder: (evt, gestureState) => true,
			onMoveShouldSetPanResponderCapture: (evt, gestureState) => true,
			onResponderTerminationRequest: (evt, gestureState) => false,
			onPanResponderGrant: (evt, gestureState) => {
				if (this.props.onPress) {
					this.props.onPress();
				}
			},
			onPanResponderTerminationRequest: (evt, gestureState) => true,
			onShouldBlockNativeResponder: (evt, gestureState) => true,
		});
	}

	render() {
		return (
			<View
				{...this._panResponder.panHandlers}
				style={this.props.style}
			>
				{this.props.children}
			</View>
		);
	}
}
