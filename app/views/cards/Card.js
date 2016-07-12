'use strict'

import React from 'react'
var css = require('../styles/css');

export default class Card extends React.Component {

  render: function() {
    <View style={css.card_main}>
      <CardHeader title={this.props.title} />
      {children}
    </View>
  }
}
