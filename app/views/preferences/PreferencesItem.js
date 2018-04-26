import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
	View,
	Text,
	Switch,
	Platform,
	Animated,
	Easing,
	StyleSheet,
} from 'react-native'
import Icon from 'react-native-vector-icons/MaterialIcons'

import { COLOR_MGREY, COLOR_WHITE } from '../../styles/ColorConstants'
import { MAX_CARD_WIDTH } from '../../styles/LayoutConstants'

// Row item for sortable-list component
class PrefItem extends Component {
	constructor(props) {
		super(props)

		this._active = new Animated.Value(0)

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
		}

		this._noTouched = false
	}

	componentWillReceiveProps(nextProps) {
		if (this.props.active !== nextProps.active) {
			Animated.timing(this._active, {
				duration: 300,
				easing: Easing.bounce,
				toValue: Number(nextProps.active),
			}).start()
		}
	}

	render() {
		const { data, cards } = this.props
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
				<View style={styles.switchContainer}>
					<Switch
						onValueChange={value => this.props.setCardState(data.id, value)}
						value={cards[data.id].active}
					/>
				</View>
			</Animated.View>
		)
	}
}

const styles = StyleSheet.create({
	list_row: {
		flexDirection: 'row',
		alignItems: 'center',
		width: MAX_CARD_WIDTH,
		borderBottomWidth: 1,
		borderBottomColor: COLOR_MGREY,
		...Platform.select({
			ios: {
				shadowOpacity: 0,
				shadowOffset: { height: 2, width: 2 },
				shadowRadius: 2,
			},

			android: {
				margin: 0,
				elevation: 0,
				backgroundColor: COLOR_WHITE
			},
		})
	},
	icon: { padding: 7 },
	name_text: { flex: 1, margin: 7, fontSize: 18 },
	switchContainer: { width: 50, height: 50, justifyContent: 'center', alignItems: 'center', marginRight: 10 },
})

function mapStateToProps(state, props) {
	return { cards: state.cards.cards }
}

function mapDispatchtoProps(dispatch) {
	return {
		setCardState: (id, state) => {
			dispatch({ type: 'UPDATE_CARD_STATE', id, state })
		}
	}
}

export default connect(mapStateToProps, mapDispatchtoProps)(PrefItem)
