import React from 'react';
import { View, Text } from 'react-native';

const css = require('../../styles/css');

export default class CardHeader extends React.Component {
	render() {
		return (
			<View style={css.card_container_main}>
				<Text style={css.card_title_main}>{this.props.title}</Text>
				{this.props.menu}
			</View>
		);
	}
}
