/*
  ReactNativeCircleCheckbox 0.1.3
  https://github.com/ParamoshkinAndrew/ReactNativeCircleCheckbox
  (c) 2016 Andrew Paramoshkin <paramoshkin.andrew@gmail.com>
  ReactNativeCircleCheckbox may be freely distributed under the MIT license.
 */
// Using this for now because owner isn't responding to github issue

'use strict'

import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {
  StyleSheet,
  View,
  Text,
  TouchableOpacity,
  ViewPropTypes
} from 'react-native';
import COLOR from '../../styles/ColorConstants';

class CircleCheckBox extends Component {

  static propTypes = {
   checked: PropTypes.bool,
   label: PropTypes.string,
   outerSize: PropTypes.number,
   filterSize: PropTypes.number,
   innerSize: PropTypes.number,
   outerColor: PropTypes.string,
   filterColor: PropTypes.string,
   innerColor: PropTypes.string,
   onToggle: PropTypes.func.isRequired,
   labelPosition: PropTypes.oneOf(['right', 'left']),
   styleCheckboxContainer: ViewPropTypes.style,
   styleLabel: Text.propTypes.style,
  };

  static defaultProps = {
    checked: false,
    outerSize: 18,
    filterSize: 16,
    innerSize: 13,
    outerColor: COLOR.MORANGE,
    filterColor: 'white',
    innerColor: COLOR.MORANGE,
    label: '',
    labelPosition: 'right',
    styleLabel: {}
  };

  constructor(props) {
    super(props);
    var outerSize = (parseInt(props.outerSize) < 10 || isNaN(parseInt(props.outerSize))) ? 10 : parseInt(props.outerSize);
    var filterSize = (parseInt(props.filterSize) > outerSize + 3 || isNaN(parseInt(props.filterSize))) ? outerSize - 3 : parseInt(props.filterSize);
    var innerSize = (parseInt(props.innerSize) > filterSize + 5 || isNaN(parseInt(props.innerSize))) ? filterSize - 5 : parseInt(props.innerSize);

    var customStyle = StyleSheet.create({
      _circleOuterStyle: {
        width: outerSize,
        height: outerSize,
        borderRadius: outerSize/2,
        backgroundColor: props.outerColor
      },
      _circleFilterStyle: {
        width: filterSize,
        height: filterSize,
        borderRadius: filterSize/2,
        backgroundColor: props.filterColor
      },
      _circleInnerStyle: {
        width: innerSize,
        height: innerSize,
        borderRadius: innerSize/2,
        backgroundColor: props.innerColor
      }
    });

    this.state = {
      customStyle: customStyle
    }
  }

  render() {
    return (
      <TouchableOpacity onPress={this._onToggle.bind(this)}>
        <View style={[styles.checkBoxContainer, this.props.styleCheckboxContainer]}>
          {this._renderLabel('left')}
          <View style={[styles.alignStyle, this.state.customStyle._circleOuterStyle]}>
            <View style={[styles.alignStyle, this.state.customStyle._circleFilterStyle]}>
              {this._renderInner()}
            </View>
          </View>
          {this._renderLabel('right')}
        </View>
      </TouchableOpacity>
    );
  }

  _onToggle() {
    if(this.props.onToggle) {
      this.props.onToggle(!this.props.checked);
    }
  }

  _renderInner() {
    return this.props.checked ? (<View style={this.state.customStyle._circleInnerStyle} />) : (<View/>);
  }

  _renderLabel(position) {
    var templ = (<View></View>);
    if ((this.props.label.length > 0) && (position === this.props.labelPosition)) {
      templ = (<Text style={[styles.checkBoxLabel, this.props.styleLabel]}>{this.props.label}</Text>);
    }
    return templ;

  }
}

var styles = StyleSheet.create({
  checkBoxContainer: {
    flexDirection: 'row',
    alignItems: 'center'
  },
  alignStyle: {
    justifyContent: 'center',
    alignItems: 'center'
  },
  checkBoxLabel: {
    fontSize: 18,
    fontWeight: '300',
    marginHorizontal: 10,
  }
});

module.exports = CircleCheckBox;
