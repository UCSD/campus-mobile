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

	render() {
		if (this.props.source && this.props.source.uri && this.state.validImage) {
			return (
				<Image
					{...this.props}
					onError={() => this.setState({ validImage: false })}
				/>
			);
		} else {
			return null;
		}
	}
}

export default SafeImage;
