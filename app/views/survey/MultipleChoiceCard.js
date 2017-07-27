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

export default class MultipleChoiceCard extends React.Component {

	render() {
		return (
			<DismissibleCard ref={(c) => { this._card = c; }}>
				<View style={css.card_text_container}>
					<Text style={css.card_button_text}>
						Are you sure you wanna dismiss me?
					</Text>
				</View>
				<View style={css.card_row_container}>
					<Touchable style={css.card_button_container} onPress={() => this._card.dismissCard()}>
						<Text style={css.card_button_text}>Yes</Text>
					</Touchable>
					<Touchable style={css.card_button_container} onPress={() => logger.log('No')}>
						<Text style={css.card_button_text}>No</Text>
					</Touchable>
				</View>
				<View style={css.card_footer_container}>
					<Touchable style={css.card_button_container} onPress={() => this._card.dismissCard()}>
						<Text style={css.card_button_text}>Maybe</Text>
					</Touchable>
					<Touchable style={css.card_button_container} onPress={() => logger.log('No')}>
						<Text style={css.card_button_text}>Surprise Me</Text>
					</Touchable>
				</View>
			</DismissibleCard>
		);
	}
}
