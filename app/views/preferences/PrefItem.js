import React, { Component } from 'react';
import {
	Text,
	Switch,
	Platform,
	Animated,
	Easing,
	StyleSheet,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';

import {
	COLOR_LGREY,
	COLOR_MGREY,
} from '../../styles/ColorConstants';
import {
	MAX_CARD_WIDTH,
} from '../../styles/LayoutConstants';
import NoTouchy from '../common/NoTouchy';

// Row item for sortable-list component
export default class PrefItem extends Component {
	constructor(props) {
		super(props);

		this._active = new Animated.Value(0);

		this._style = {
			...Platform.select({
				ios: {
					shadowOpacity: this._active.interpolate({
						inputRange: [0, 1],
						outputRange: [0, 0.2],
					}),
					shadowRadius: this._active.interpolate({
						inputRange: [0, 1],
						outputRange: [2, 10],
					}),
				},

				android: {
					marginTop: this._active.interpolate({
						inputRange: [0, 1],
						outputRange: [0, 10],
					}),
					marginBottom: this._active.interpolate({
						inputRange: [0, 1],
						outputRange: [0, 10],
					}),
					elevation: this._active.interpolate({
						inputRange: [0, 1],
						outputRange: [2, 6],
					}),
				},
			})
		};

		this.state = {
			switchState: this.props.data.active
		};
	}

	componentWillReceiveProps(nextProps) {
		if (this.props.active !== nextProps.active) {
			Animated.timing(this._active, {
				duration: 300,
				easing: Easing.bounce,
				toValue: Number(nextProps.active),
			}).start();
		}
	}

	// Toggle can come from switch or NoTouchy
	_handleToggle = (fromSwitch) => {
		const { data, updateState } = this.props;

		if (!fromSwitch) {
			updateState(data.id, !this.state.switchState);
			this.setState({ switchState: !this.state.switchState });
		} else {
			updateState(data.id, this.state.switchState);
		}
	}

	render() {
		const { data } = this.props;
		return (
			<Animated.View
				style={[styles.list_row, this._style]}
			>
				<Icon
					style={styles.icon}
					name="drag-handle"
					size={20}
				/>
				<Text style={styles.name_text}>{data.name}</Text>
				<NoTouchy
					style={styles.switchContainer}
					onPress={() => this._handleToggle(false)}
				>
					<Switch
						onValueChange={(value) => this._handleToggle(true)}
						value={this.state.switchState}
					/>
				</NoTouchy>
			</Animated.View>
		);
	}
}

const styles = StyleSheet.create({
	list_row: { backgroundColor: COLOR_LGREY, flexDirection: 'row', alignItems: 'center', width: MAX_CARD_WIDTH, borderBottomWidth: 1, borderBottomColor: COLOR_MGREY ,
		...Platform.select({
			ios: {
				shadowOpacity: 0,
				shadowOffset: { height: 2, width: 2 },
				shadowRadius: 2,
			},

			android: {
				margin: 0,
				elevation: 0,
			},
		})
	},
	icon: { padding: 7 },
	name_text: { flex: 1, margin: 7, fontSize: 18 },
	switchContainer: { backgroundColor: COLOR_LGREY, width: 50, height: 50, justifyContent: 'center', alignItems: 'center' },
});
