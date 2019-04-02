import React, { Component } from 'react'
import { StyleSheet, View, Text, TouchableOpacity } from 'react-native'
import css from '../../styles/css'
import COLOR from '../../styles/ColorConstants'

class CircleCheckBox extends Component {
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
		styleCheckboxContainer: '',
		styleLabel: {}
	}

	constructor(props) {
		super(props)

		const outerSize = (parseInt(props.outerSize) < 10 || Number.isNaN(parseInt(props.outerSize))) ? 10 : parseInt(props.outerSize),
			filterSize = (parseInt(props.filterSize) > outerSize + 3 || Number.isNaN(parseInt(props.filterSize))) ? outerSize - 3 : parseInt(props.filterSize),
			innerSize = (parseInt(props.innerSize) > filterSize + 5 || Number.isNaN(parseInt(props.innerSize))) ? filterSize - 5 : parseInt(props.innerSize)

		const customStyles = StyleSheet.create({
			_circleOuterStyle: {
				width: outerSize,
				height: outerSize,
				borderRadius: outerSize / 2,
				backgroundColor: props.outerColor
			},
			_circleFilterStyle: {
				width: filterSize,
				height: filterSize,
				borderRadius: filterSize / 2,
				backgroundColor: props.filterColor
			},
			_circleInnerStyle: {
				width: innerSize,
				height: innerSize,
				borderRadius: innerSize / 2,
				backgroundColor: props.innerColor
			}
		})

		this.state = { customStyle: customStyles }
		this._onToggle = this._onToggle.bind(this)
	}

	_onToggle() {
		if (this.props.onToggle) {
			this.props.onToggle(!this.props.checked)
		}
	}

	_renderInner() {
		return this.props.checked ? (<View style={this.state.customStyle._circleInnerStyle} />) : (<View />)
	}

	_renderLabel(position) {
		let templ = (<View />)
		if ((this.props.label.length > 0) && (position === this.props.labelPosition)) {
			templ = (<Text style={[css.ccb_checkBoxLabel, this.props.styleLabel]}>{this.props.label}</Text>)
		}
		return templ
	}

	render() {
		return (
			<TouchableOpacity onPress={this._onToggle}>
				<View style={[css.ccb_checkBoxContainer, this.props.styleCheckboxContainer]}>
					{this._renderLabel('left')}
					<View style={[css.ccb_center, this.state.customStyle._circleOuterStyle]}>
						<View style={[css.ccb_center, this.state.customStyle._circleFilterStyle]}>
							{this._renderInner()}
						</View>
					</View>
					{this._renderLabel('right')}
				</View>
			</TouchableOpacity>
		)
	}
}

module.exports = CircleCheckBox
