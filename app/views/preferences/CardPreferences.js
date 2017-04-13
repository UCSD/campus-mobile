import React, { Component } from 'react';
import {
	View,
	Text,
	Switch,
} from 'react-native';

import { connect } from 'react-redux';

import { setCardState } from '../../actions';
import Card from '../card/Card';
import css from '../../styles/css';

// View for user to manage preferences, including which cards are visible
export default class CardPreferences extends Component {
	_setCardState = (card, state) => {
		this.props.setCardState(card, state);
		this.props.updateScroll(); // reset homeview scroll
	}

	// render out all the cards, currently showing or not
	_renderCards = () => {
		return Object.keys(this.props.cards).map(key => {

			const cardActive = this.props.cards[key].active;
			const cardName = this.props.cards[key].name;

			return (
				<View key={key} style={css.preferencesContainer}>
					<View style={css.spacedRow}>
						<View style={css.centerAlign}>
							<Text style={css.prefCardTitle}>{cardName}</Text>
						</View>
						<View style={css.centerAlign}>
							<Switch
								onValueChange={(value) => { this._setCardState(key, value); }}
								value={cardActive}
							/>
						</View>
					</View>
				</View>
			);
		});
	}

	render() {
		return (
			<Card id="cards" title="Cards" hideMenu={true}>
				<View style={css.card_content_full_width}>
					<View style={css.column}>
						{this._renderCards()}
					</View>
				</View>
			</Card>
		);
	}
}

function mapStateToProps(state, props) {
	return {
		cards: state.cards,
	};
}

function mapDispatchtoProps(dispatch) {
	return {
		setCardState: (card, state) => {
			dispatch(setCardState(card, state));
		},
		updateScroll: () => {
			dispatch({ type: 'UPDATE_HOME_SCROLL', scrollY: 0 });
		}
	};
}

module.exports = connect(mapStateToProps, mapDispatchtoProps)(CardPreferences);
