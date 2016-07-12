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

  render() {
    <View style={css.card_main}>
      <CardHeader title={this.props.title} />
      {this.props.children}
    </View>
  }
}
