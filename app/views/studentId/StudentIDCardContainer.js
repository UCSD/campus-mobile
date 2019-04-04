import React from 'react'
import { connect } from 'react-redux'
import SystemSetting from 'react-native-system-setting'
import StudentIDCard from './StudentIDCard'

class StudentIDCardContainer extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			barcodeModalVisible: false
		}
	}

	setMaxBrightness = () => {
		// Set max brightness
		SystemSetting.getAppBrightness().then((brightness) => {
			this.setState({ deviceBrightness: brightness })
			SystemSetting.setAppBrightness(1.0)
		})
	}

	restoreBrightness = () => {
		// Restore original brightness
		SystemSetting.setAppBrightness(this.state.deviceBrightness)
	}

	toggleModal = () => {
		this.state.barcodeModalVisible ? this.restoreBrightness() : this.setMaxBrightness()
		this.setState({ barcodeModalVisible: !this.state.barcodeModalVisible })
	}

	render() {
		const { studentProfile } = this.props
		return (
			<StudentIDCard
				data={studentProfile.data}
				barcodeModalVisible={this.state.barcodeModalVisible}
				toggleModal={this.toggleModal}
			/>
		)
	}
}

const mapStateToProps = state => (
	{
		studentProfile: state.studentProfile
	}
)

export default connect(mapStateToProps)(StudentIDCardContainer)
