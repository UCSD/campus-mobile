import React from 'react';
import {
	View,
} from 'react-native';

import CardHeader from './CardHeader';

const css = require('../../styles/css');

export default class Card extends React.Component {
	setNativeProps(props) {
		this._card.setNativeProps(props);
	}

	refresh(refreshType) {
		return;
	}
	render() {
		return (
			<View style={css.card_main} ref={(i) => { this._card = i; }}>
				<CardHeader title={this.props.title} cardRefresh={this.props.cardRefresh} isRefreshing={this.props.isRefreshing} />
				{this.props.children}
			</View>
		);
	}
}
