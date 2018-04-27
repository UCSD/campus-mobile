import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
	View,
	Text,
	Switch,
	Platform,
	Animated,
	Easing,
} from 'react-native'
import Icon from 'react-native-vector-icons/MaterialIcons'

import css from '../../styles/css'

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
				style={[css.us_list_row, this._style]}
			>
				<Icon
					style={css.us_icon}
					name="drag-handle"
					size={20}
				/>
				<Text style={css.us_name_text}>{data.name}</Text>
				<View style={css.us_switchContainer}>
					<Switch
						onValueChange={value => this.props.setCardState(data.id, value)}
						value={cards[data.id].active}
					/>
				</View>
			</Animated.View>
		)
	}
}

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
