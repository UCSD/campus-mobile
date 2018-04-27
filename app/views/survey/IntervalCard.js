import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
} from 'react-native';

import DismissibleCard from '../card/DismissibleCard';
import Touchable from '../common/Touchable';

const css = require('../../styles/css');
const logger = require('../../util/logger');

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
					<Touchable style={css.card_button_container} onPress={() => this._card.dismissCard()}>
						<Text style={css.card_button_text}>0</Text>
					</Touchable>
					<Touchable style={css.card_button_container} onPress={() => logger.log('No')}>
						<Text style={css.card_button_text}>1</Text>
					</Touchable>
					<Touchable style={css.card_button_container} onPress={() => this._card.dismissCard()}>
						<Text style={css.card_button_text}>2</Text>
					</Touchable>
					<Touchable style={css.card_button_container} onPress={() => logger.log('No')}>
						<Text style={css.card_button_text}>3</Text>
					</Touchable>
					<Touchable style={css.card_button_container} onPress={() => this._card.dismissCard()}>
						<Text style={css.card_button_text}>4</Text>
					</Touchable>
				</View>
			</DismissibleCard>
		);
	}
}
