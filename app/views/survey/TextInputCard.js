import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	TextInput
} from 'react-native';

import DismissibleCard from '../card/DismissibleCard';

const css = require('../../styles/css');
const logger = require('../../util/logger');

export default class TextInputCard extends React.Component {

	render() {
		return (
			<DismissibleCard ref={(c) => { this._card = c; }}>
				<View style={css.card_text_container}>
					<Text style={css.card_button_text}>
						Enter 'Dismiss' to dismiss card.
					</Text>
				</View>
				<View style={css.card_row_container}>
					<TextInput
						onChangeText={(text) => this.setState({ nameText: text })}
						placeholder="Answer here"
						style={css.feedback_text}
					/>
				</View>
				<View style={css.card_footer_container}>
					<TouchableHighlight style={css.card_button_container} underlayColor="#DDD" onPress={() => logger.log('No')}>
						<Text style={css.card_button_text}>Submit</Text>
					</TouchableHighlight>
				</View>
			</DismissibleCard>
		);
	}
}
