'use strict'

import React from 'react'
import {
	View,
	TouchableHighlight,
  Image,
	Text,
  Modal
} from 'react-native';

var css = require('../../styles/css');

// Modal with text information content and a large button (usually for dismissing the modal)
export default class InfoModal extends React.Component {
  _onPress = () => {
    if (this.props.onPress) {
      this.props.onPress(); //callback when modal is pressed
    }
  }
  render() {
    return(
      <Modal animationType={'none'} transparent={true} visible={this.props.modalVisible}>
        <View style={css.modal_container}>
          <Text style={css.modal_text_intro}>{this.props.title}</Text>
          <Text style={css.modal_text}>
            {this.props.children}
          </Text>

          <TouchableHighlight underlayColor={'rgba(200,200,200,.5)'} onPress={this._onPress}>
            <View style={css.modal_button}>
              <Text style={css.modal_button_text}>{this.props.buttonText}</Text>
            </View>
          </TouchableHighlight>
        </View>
      </Modal>
    );
  }
}
