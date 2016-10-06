'use strict'

import React from 'react'
import {
	View,
	Text,
	TouchableHighlight,
	Animated,
	PanResponder,
	Dimensions,
	TextInput
} from 'react-native';
import DismissibleCard from '../card/DismissibleCard'
 
var css = require('../../styles/css');

export default class TextInputCard extends React.Component {

	constructor(props) {
		super(props);
	}

	render() {
		return(
			<DismissibleCard ref={(c) => this._card = c}>
				<View style={css.card_text_container}>
					<Text style={css.card_button_text}>
						 Enter 'Dismiss' to dismiss card.
					</Text>
				</View>
				<View style={css.card_row_container}>
					<TextInput 
						onChangeText={(text) => this.setState({nameText: text})}
						placeholder="Answer here"
						style={css.feedback_text}
					/>
				</View>
				<View style={css.card_footer_container}>
					<TouchableHighlight style={css.card_button_container} underlayColor="#DDD" onPress={() => console.log("No")}>
						<Text style={css.card_button_text}>Submit</Text>
					</TouchableHighlight>
				</View>
			</DismissibleCard>
		);
	}
}