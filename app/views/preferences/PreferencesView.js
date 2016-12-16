import React, { Component } from 'react';
import {
	View,
	Text,
	Switch,
	StyleSheet,
	ScrollView
} from 'react-native';
import { connect } from 'react-redux';

import { setCardState } from '../../actions';
import Card from '../card/Card';

import css from '../../styles/css';

// View for user to manage preferences, including which cards are visible
export default class PreferencesView extends Component {
	_setCardState = (card, state) => {
		this.props.dispatch(setCardState(card, state));
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
								onValueChange={(value) => { this._setCardState(key, value) }}
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
			<View style={[css.main_container, css.offwhitebg]}>
				<ScrollView contentContainerStyle={css.scroll_default}>
					<Card id="cards" title="Cards">
						<View style={css.card_content_full_width}>
							<View style={css.column}>
								{this._renderCards()}
							</View>
						</View>
					</Card>
				</ScrollView>
			</View>
		);
	}
}

function mapStateToProps(state, props) {
	return {
		cards: state.cards,
	};
}

module.exports = connect(mapStateToProps)(PreferencesView);
