import React from 'react';
import {
	View,
	Text,
	Share,
} from 'react-native';
import Toast from 'react-native-simple-toast';

import Touchable from './Touchable';

class ShareContent extends React.Component {
	_shareContent = () => {
		const { message, url, title } = this.props;

		Share.share({
			message,
			url,
			title
		})
		.then(this._showResult)
		.catch((error) => console.log('Error sharing content: ' + title + error));
	}

	_showResult = (result) => {
		if (result.action === Share.sharedAction) {
			/*if (result.activityType) {
				Toast.showWithGravity(result.activityType, Toast.SHORT, Toast.CENTER);
				console.log(result.activityType);
			} else {*/
				// TODO change dialog based on copy to clipboard or other
				Toast.showWithGravity('Shared', Toast.SHORT, Toast.CENTER);
			//}
		} else if (result.action === Share.dismissedAction) {
			// dismissed
		}
	}

	render() {
		const { style, title } = this.props;

		return (
			<Touchable
				onPress={this._shareContent}
				style={style}
			>
				<Text>
					{title}
				</Text>
			</Touchable>
		);
	}
}

export default ShareContent;
