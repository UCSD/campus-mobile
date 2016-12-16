import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
} from 'react-native';

import DismissibleCard from '../card/DismissibleCard';

const css = require('../../styles/css');

export default class IntervalCard extends React.Component {

	render() {
		return (
			<DismissibleCard ref={(c) => { this._card = c; }}>
				<View style={css.card_text_container}>
					<Text style={css.card_button_text}>
						Please rate how much you would like to dismiss me.
					</Text>
				</View>
				<View style={css.card_footer_container}>
					<TouchableHighlight style={css.card_button_container} underlayColor="#DDD" onPress={() => this._card.dismissCard()}>
						<Text style={css.card_button_text}>0</Text>
					</TouchableHighlight>
					<TouchableHighlight style={css.card_button_container} underlayColor="#DDD" onPress={() => console.log('No')}>
						<Text style={css.card_button_text}>1</Text>
					</TouchableHighlight>
					<TouchableHighlight style={css.card_button_container} underlayColor="#DDD" onPress={() => this._card.dismissCard()}>
						<Text style={css.card_button_text}>2</Text>
					</TouchableHighlight>
					<TouchableHighlight style={css.card_button_container} underlayColor="#DDD" onPress={() => console.log('No')}>
						<Text style={css.card_button_text}>3</Text>
					</TouchableHighlight>
					<TouchableHighlight style={css.card_button_container} underlayColor="#DDD" onPress={() => this._card.dismissCard()}>
						<Text style={css.card_button_text}>4</Text>
					</TouchableHighlight>
				</View>
			</DismissibleCard>
		);
	}
}
