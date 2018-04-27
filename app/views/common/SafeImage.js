import React from 'react'
import { Image } from 'react-native'

class SafeImage extends React.Component {
	constructor(props) {
		super(props)
		this.state = { validImage: true }
	}

	_handleError = (event) => {
		console.log(`Error loading image ${this.props.source.uri}:`, event.nativeEvent.error)
		this.setState({ validImage: false })
	}

	render() {
		let selectedResizeMode = 'contain'
		if (this.props.resizeMode) {
			selectedResizeMode = this.props.resizeMode
		}
		if (this.props.source && this.props.source.uri && this.state.validImage) {
			return (
				<Image
					{...this.props}
					onError={this._handleError}
					resizeMode={selectedResizeMode}
				/>
			)
		} else {
			return null
		}
	}
}

export default SafeImage
