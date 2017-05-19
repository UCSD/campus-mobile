import React from 'react';
import {
	Animated,
	StyleSheet
} from 'react-native';

import CardHeader from './CardHeader';
import {
	COLOR_DGREY,
	COLOR_LGREY
} from '../../styles/ColorConstants';

export default class DismissibleCard extends React.Component {

	constructor(props) {
		super(props);
		this.state = {
			isDismissed: false,
			fadeAnim: new Animated.Value(1),
			pan: new Animated.ValueXY(), // inits to zero
		};
		/*
		this.state.panResponder = PanResponder.create({
			onStartShouldSetPanResponder: (e, gesture) => {
				//logger.log("start: " + util.inspect(e.nativeEvent));
				return true;
			},
			onShouldBlockNativeResponder: (e, gesture) => true,
			onPanResponderGrant: (e, gesture) => {
				//logger.log("grant: " + util.inspect(gesture));
			},
			onPanResponderMove: (e, gesture) => {
				if (gesture.dx > tenth && gesture.vx > gesture.vy) {
					panning = true;

					Animated.event([null, {
						dx: this.state.pan.x, // x,y are Animated.Value
					}])(e, gesture);
				} else {

				}
			},
			onPanResponderRelease: () => {
				panning = false;

				var xPos = Number(JSON.stringify(this.state.pan.x));

				if(xPos > third) {
					this.dismissCard();
				}
				else {
					Animated.spring(
						this.state.pan, // Auto-multiplexed
						{toValue: {x: 0, friction: 3}} // Back to zero
					).start();
				}
			},
		});*/
	}

	setNativeProps(props) {
		this._card.setNativeProps(props);
	}

	dismissCard() {
		Animated.timing(
			this.state.fadeAnim,
			{ toValue: 0 }
		).start(() => this.setState({ isDismissed: true }));
	}

	render() {
		if (this.state.isDismissed) {
			return null;
		}
		else {
			/*
			return (
				<Animated.View
					style={[css.card_main, { opacity: this.state.fadeAnim }, this.state.pan.getLayout()]}
					{...this.state.panResponder.panHandlers}
					>

					{(this.props.title) ? (
						<CardHeader title={this.props.title} cardRefresh={this.props.cardRefresh} isRefreshing={this.props.isRefreshing} />) :
						(null)
					}

					{this.props.children}
				</Animated.View>
			);*/
			return (
				<Animated.View
					style={[styles.card_main, this.props.style, { opacity: this.state.fadeAnim }]}
				>
					{(this.props.title) ? (
						<CardHeader title={this.props.title} cardRefresh={this.props.cardRefresh} isRefreshing={this.props.isRefreshing} />) :
						(null)
					}
					{this.props.children}
				</Animated.View>
			);
		}
	}
}

const styles = StyleSheet.create({
	card_main: { borderWidth: 1, borderRadius: 2, borderColor: COLOR_DGREY, backgroundColor: COLOR_LGREY, margin: 6, alignItems: 'flex-start', justifyContent: 'center', overflow: 'hidden' },
});
