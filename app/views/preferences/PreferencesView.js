import React, { Component } from 'react';
import {
	View,
	Text,
	Switch,
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
			const cardActive = this.props.cards[key];
			return (
				<View key={key}>
					<View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
						<View>
							<Text>{key}</Text>
						</View>
						<View>
							<Switch
								onValueChange={(value) => this._setCardState(key, value)}
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
			<View style={{ flex: 1, backgroundColor: 'white' }}>
				<ScrollView>
					<Card id="cards" title="Cards">
						<View style={css.card__container}>
							<View style={{ flex: 1, flexDirection: 'column' }}>
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
