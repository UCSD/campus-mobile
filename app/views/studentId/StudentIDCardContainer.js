import React from 'react'
import { connect } from 'react-redux'
import StudentIDCard from './StudentIDCard'


class StudentIDCardContainer extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			barcodeModalVisible: false
		}
	}

	_toggleModal = () => {
		this.setState({ barcodeModalVisible: !this.state.barcodeModalVisible })
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

