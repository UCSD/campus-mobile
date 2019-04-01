import React from 'react'
import { connect } from 'react-redux'
import StudentIDCard from './StudentIDCard'


class StudentIDCardContainer extends React.Component {
	render() {
		const { studentProfile } = this.props
		return (
			<StudentIDCard
				data={studentProfile.data}
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

