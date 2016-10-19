'use strict'

import React from 'react'
import {
	View,
} from 'react-native';
import CardHeader from './CardHeader'

var css = require('../../styles/css');

export default class Card extends React.Component {

  refresh(refreshType) {
    return;
  }

  setNativeProps(props) {
    this._card.setNativeProps(props);
  }

  render() {
	return (
		<View style={css.card_main} ref={(i) => this._card = i}>
			<CardHeader id={this.props.id} title={this.props.title} cardRefresh={this.props.cardRefresh} isRefreshing={this.props.isRefreshing} />
			{this.props.children}
		</View>
		);
	}
}
