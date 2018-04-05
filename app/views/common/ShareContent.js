import React from 'react'
import { Text, Share } from 'react-native'
import Toast from 'react-native-simple-toast'

import css from '../../styles/css'
import Touchable from './Touchable'

class ShareContent extends React.Component {
	_shareContent = () => {
		const { message, url, title } = this.props

		Share.share({
			message,
			url,
			title
		})
			.then(this._showResult)
			.catch(error => console.log('Error sharing content: ' + title + error))
	}

	_showResult = (result) => {
		if (result.action === Share.sharedAction) {
			Toast.showWithGravity('Shared', Toast.SHORT, Toast.CENTER)
		}
	}

	render() {
		const { title } = this.props
		return (
			<Touchable onPress={this._shareContent} style={css.share_button}>
				<Text style={css.share_button_text}>
					{title}
				</Text>
			</Touchable>
		)
	}
}

export default ShareContent
