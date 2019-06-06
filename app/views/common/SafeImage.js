import React from 'react'
import { ImageBackground, ActivityIndicator, View } from 'react-native'
import css from '../../styles/css'

class SafeImage extends React.Component {
	constructor(props) {
		super(props)
		this.state = { validImage: true, loading: true }
	}

	_handleError = (event) => {
		console.log(`Error loading image ${this.props.source.uri}:`, event.nativeEvent.error)
		this.setState({ validImage: false })
	}

	_handleOnLoadEnd = () => {
		this.setState({ loading: false })
	}

	render() {
		let selectedResizeMode = 'contain'
		if (this.props.resizeMode) {
			selectedResizeMode = this.props.resizeMode
		}
		if (this.props.source && this.props.source.uri && this.state.validImage) {
			return (
				<ImageBackground
					{...this.props}
					onError={this._handleError}
					resizeMode={selectedResizeMode}
					onLoadEnd={this._handleOnLoadEnd}
				>
					{this.state.loading ? <ActivityIndicator size="small" style={css.safe_image_loading_activity_indicator} /> : null}
				</ImageBackground>
			)
		} else if (this.props.onFailure) {
			return this.props.onFailure
		} else {
			return null
		}
	}
}


export default SafeImage
