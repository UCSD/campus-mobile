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

	componentDidMount() {
		this.props.retryPressed()
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
		const {
			studentProfile,
			studentProfileRequestStatus,
			studentNameRequestStatus,
			studentPhotoRequestStatus,
			studentNameRequestError,
			studentPhotoRequestError,
			studentProfileRequestError,
			retryPressed,
		} = this.props

		return (
			<StudentIDCard
				studentProfile={studentProfile}
				barcodeModalVisible={this.state.barcodeModalVisible}
				studentPhotoRequestStatus={studentPhotoRequestStatus}
				studentProfileRequestStatus={studentProfileRequestStatus}
				studentNameRequestStatus={studentNameRequestStatus}
				studentNameRequestError={studentNameRequestError}
				studentPhotoRequestError={studentPhotoRequestError}
				studentProfileRequestError={studentProfileRequestError}
				retryPressed={retryPressed}
				toggleModal={this.toggleModal}
			/>
		)
	}
}

const mapStateToProps = state => (
	{
		studentProfile: state.studentProfile,
		studentProfileRequestStatus: state.requestStatuses.GET_STUDENT_PROFILE,
		studentNameRequestStatus: state.requestStatuses.GET_STUDENT_NAME,
		studentPhotoRequestStatus: state.requestStatuses.GET_STUDENT_PHOTO,
		studentNameRequestError: state.requestErrors.GET_STUDENT_NAME,
		studentPhotoRequestError: state.requestErrors.GET_STUDENT_PHOTO,
		studentProfileRequestError: state.requestErrors.GET_STUDENT_PROFILE
	}
)

const mapDispatchToProps = (dispatch, ownProps) => (
	{
		retryPressed: () => {
			dispatch({ type: 'UPDATE_STUDENT_PROFILE' })
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(StudentIDCardContainer)
