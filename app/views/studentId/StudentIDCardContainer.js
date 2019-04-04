import React from 'react'
import { Alert } from 'react-native'
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

	_toggleModal = () => {
		this.state.barcodeModalVisible ? this._restoreBrightness() : this._setMaxBrightness()
		this.setState({ barcodeModalVisible: !this.state.barcodeModalVisible })
	}

	_setMaxBrightness = () => {
		// Save original brightness to restore later
		SystemSetting.saveBrightness()

		// Set max brightness
		SystemSetting.setBrightnessForce(1.0).then((success) => {
			!success && Alert.alert(
				'Unable to Increase Brightness',
				'For easier scanning, it is recommended to temporarily set your device to it\'s maximum brightness setting.',
				[
					{ 'text': 'Allow', style: 'Cancel' },
					{ 'text': 'Open Settings', onPress: () => SystemSetting.grantWriteSettingPremission() }
				]
			)
		})
	}

	_restoreBrightness = () => {
		// Restore original brightness
		SystemSetting.restoreBrightness()
	}

	render() {
		const { studentProfile } = this.props
		return (
			<StudentIDCard
				data={studentProfile.data}
				barcodeModalVisible={this.state.barcodeModalVisible}
				toggleModal={this._toggleModal}
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
