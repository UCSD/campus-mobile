import React, { Component } from 'react';
import {
	View,
	StyleSheet,
} from 'react-native';

import { connect } from 'react-redux';
import SortableList from 'react-native-sortable-list';

import PrefItem from './PrefItem';
import Card from '../card/Card';
import {
	MAX_CARD_WIDTH,
} from '../../styles/LayoutConstants';

// View for user to manage preferences, including which cards are visible
export default class CardPreferences extends Component {
	componentWillMount() {
		this.setState({ cardObject: this.getCardObject(this.props.cards, this.props.cardOrder) });
	}

	// Only setState if nextProps cardOrder is dfferent. Fixes flickering from re-render on android
	componentWillReceiveProps(nextProps) {
		if (!this.arraysEqual(nextProps.cardOrder, this.props.cardOrder)) {
			this.setState({ cardObject: this.getCardObject(nextProps.cards, nextProps.cardOrder) });
		}
	}

	setCardState = (id, state) => {
		this.props.setCardState(id, state);
		this.props.updateScroll(); // reset homeview scroll
	}

	getCardObject = (cards, cardOrder) => {
		const cardArray = [];
		const cardObject = {};

		if (Array.isArray(cardOrder)) {
			for (let i = 0; i < cardOrder.length; ++i) {
				const key = cardOrder[i];
				cardArray.push(cards[key]);
				cardObject[i] = cards[key];
			}
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

	// Checks if array content is the same
	arraysEqual = (arr1, arr2) => {
		if (arr1.length !== arr2.length) {
			return false;
		}
		for (let i = arr1.length; i--;) {
			if (arr1[i] !== arr2[i]) {
				return false;
			}
		}
		return true;
	}

	_handleRelease = () => {
		if (Array.isArray(this._order)) {
			const orderedCards = this.getOrderedArray();
			this.props.orderCards(orderedCards);
		}
		this.props.toggleScroll(); // toggle parent scroll
	}

	render() {
		return (
			<Card id="cards" title="Cards" hideMenu={true}>
				<View style={styles.list_container}>
					<SortableList
						scrollEnabled={false}
						data={this.state.cardObject}
						renderRow={
							({ data, active, disabled }) => {
								// Hide specialEvents option if there is no specialEventsData
								if (data.id === 'specialEvents' && !this.props.specialEventsData) {
									return null;
								} 
								else {
									// Using cardActive instead of data.active bc state isn't updated
									// everytime
									// Also, mildly confusing..but active prop from renderRow means
									// the row has been grabbed
									return (
										<PrefItem
											data={data}
											cardActive={this.props.cards[data.id].active}
											active={active}
											updateState={this.setCardState}
										/>
									);
								}
							}
						}
						onActivateRow={(key) => this.props.toggleScroll()}
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
		cardOrder: state.cards.cardOrder,
		specialEventsData: state.specialEvents.data,
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

const styles = StyleSheet.create({
	list_container: { width: MAX_CARD_WIDTH },
});

module.exports = connect(mapStateToProps, mapDispatchtoProps)(CardPreferences);
