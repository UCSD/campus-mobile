import React, { Component } from 'react';
import {
	View,
	Text,
	Switch,
	StyleSheet,
	Platform,
	Animated,
	Easing
} from 'react-native';

import { connect } from 'react-redux';
import SortableList from 'react-native-sortable-list';
import Icon from 'react-native-vector-icons/MaterialIcons';

import Card from '../card/Card';
import { getMaxCardWidth } from '../../util/general';
import {
	COLOR_LGREY,
	COLOR_MGREY
} from '../../styles/ColorConstants';

// View for user to manage preferences, including which cards are visible
export default class CardPreferences extends Component {
	componentWillMount() {
		this.setState({ cardObject: this.getCardObject(this.props.cards, this.props.cardOrder) });
	}

	componentWillReceiveProps(nextProps) {
		this.setState({ cardObject: this.getCardObject(nextProps.cards, nextProps.cardOrder) });
	}

	setCardState = (id, state) => {
		this.props.setCardState(id, state);
		this.props.updateScroll(); // reset homeview scroll
	}

	getCardObject = (cards, cardOrder) => {
		const cardArray = [];
		const cardObject = {};
		for (let i = 0; i < cardOrder.length; ++i) {
			const key = cardOrder[i];
			cardArray.push(cards[key]);
			cardObject[i] = cards[key];
		}
		return cardObject;
	}

	getOrderedArray = () => {
		const orderArray = [];
		for (let i = 0; i < this._order.length; ++i) {
			orderArray.push(this.state.cardObject[this._order[i]].id);
		}
		return orderArray;
	}

	_handleRelease = () => {
		if (this._order) {
			const orderedCards = this.getOrderedArray();
			this.props.orderCards(orderedCards);
		}
	}

	render() {
		return (
			<Card id="cards" title="Cards" hideMenu={true}>
				<View style={styles.list_container}>
					<SortableList
						scrollEnabled={false}
						data={this.state.cardObject}
						renderRow={
							({ data, active, disabled }) =>
								<PrefItem
									data={data}
									active={active}
									updateState={this.setCardState}
								/>
						}
						onChangeOrder={(nextOrder) => { this._order = nextOrder; }}
						onReleaseRow={(key) => this._handleRelease()}
					/>
				</View>
			</Card>
		);
	}
}

function mapStateToProps(state, props) {
	return {
		cards: state.cards.cards,
		cardOrder: state.cards.cardOrder
	};
}

function mapDispatchtoProps(dispatch) {
	return {
		orderCards: (newOrder) => {
			dispatch({ type: 'ORDER_CARDS', newOrder });
		},
		setCardState: (id, state) => {
			dispatch({ type: 'UPDATE_CARD_STATE', id, state });
		},
		updateScroll: () => {
			dispatch({ type: 'UPDATE_HOME_SCROLL', scrollY: 0 });
		}
	};
}

class PrefItem extends React.Component {

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

	_handleToggle = (value) => {
		const { data, updateState } = this.props;
		this.setState({ switchState: value });
		updateState(data.id, value);
	}

	render() {
		const { data } = this.props;
		return (
			<Animated.View
				style={[styles.list_row, this._style]}
			>
				<Icon
					name="drag-handle"
					size={20}
				/>
				<Text style={styles.name_text}>{data.name}</Text>
				<Switch
					onValueChange={(value) => { this._handleToggle(value); }}
					value={this.state.switchState}
				/>
			</Animated.View>
		);
	}
}

const styles = StyleSheet.create({
	list_row: { backgroundColor: COLOR_LGREY, flexDirection: 'row', alignItems: 'center', width: getMaxCardWidth(), padding: 7, borderBottomWidth: 1, borderBottomColor: COLOR_MGREY ,
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
	name_text: { flex: 1, margin: 7, fontSize: 18 },
	list_container: { width: getMaxCardWidth() },
});

module.exports = connect(mapStateToProps, mapDispatchtoProps)(CardPreferences);
