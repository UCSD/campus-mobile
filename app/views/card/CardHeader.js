import React from 'react';
import { View, Text } from 'react-native';

const css = require('../../styles/css');

const CardHeader = ({ title, menu }) => (
	<View style={css.card_title_main}>
		<Text style={css.card_title_text}>{title}</Text>
		{menu}
	</View>
);

export default CardHeader;
