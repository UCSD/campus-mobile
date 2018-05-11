/* eslint object-curly-newline: 0 */
import React, { Component } from 'react'
import { View, Text } from 'react-native'
import moment from 'moment'

import FAIcon from 'react-native-vector-icons/FontAwesome'
import css from '../../styles/css'

class LastUpdated extends Component {
	componentDidMount() {
		this.interval = setInterval(() => this.forceUpdate(), 60000)
	}

	componentWillUnmount() {
		clearInterval(this.interval)
	}

	render() {
		if (this.props.lastUpdated) {
			let warningComponent = null
			let messageText = `Last updated: ${moment(this.props.lastUpdated).fromNow()}`
			if (this.props.warning) {
				warningComponent = (
					<FAIcon
						name="warning"
						style={[css.last_updated_err_icon, css.last_updated_err_icon_warn]}
					/>
				)
				messageText = this.props.warning
			}
			else if (this.props.error) {
				warningComponent = (
					<FAIcon
						name="warning"
						style={[css.last_updated_err_icon, css.last_updated_err_icon_error]}
					/>
				)
				messageText = this.props.error
			}
			return (
				<View style={[css.card_last_updated, this.props.style]}>
					{warningComponent}
					<Text style={css.card_last_updated_text}>
						{messageText}
					</Text>
				</View>
			)
		} else {
			return null
		}
	}
}

export default LastUpdated
