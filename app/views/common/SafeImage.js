import React from 'react';
import {
	Image,
} from 'react-native';

class SafeImage extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			validImage: true
		};
	}

	_handleError = (error) => {
		console.log('Error loading image: ' + error);
		this.setState({ validImage: false });
	}

	render() {
		if (this.props.source && this.props.source.uri && this.state.validImage) {
			return (
				<Image
					{...this.props}
					onError={this._handleError}
					resizeMode={'contain'}
				/>
			);
		} else {
			return null;
		}
	}
}

export default SafeImage;
