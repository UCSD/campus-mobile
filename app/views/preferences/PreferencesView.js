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
			const cardActive = this.props.cards[key];
			return (
				<View key={key} style={styles.cardContainer}>
					<View style={styles.spacedRow}>
						<View style={styles.centerAlign}>
							<Text>{key}</Text>
						</View>
						<View style={styles.centerAlign}>
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
			<View style={[css.main_container, css.offwhitebg]}>
				<ScrollView contentContainerStyle={css.scroll_default}>
					<Card id="cards" title="Cards">
						<View style={css.card_content_full_width}>
							<View style={styles.column}>
								{this._renderCards()}
							</View>
						</View>
					</Card>
				</ScrollView>
			</View>
		);
	}
}

const styles = StyleSheet.create({
	cardContainer: {
		padding: 10,
		borderTopWidth: 1,
		borderTopColor: '#EEE'
	},
	spacedRow: {
		flexDirection: 'row',
		justifyContent: 'space-between'
	},
	centerAlign: {
		alignSelf: 'center',
	},
	column: {
		flex: 1,
		flexDirection: 'column',
	}
});

function mapStateToProps(state, props) {
	return {
		cards: state.cards,
	};
}

module.exports = connect(mapStateToProps)(PreferencesView);
