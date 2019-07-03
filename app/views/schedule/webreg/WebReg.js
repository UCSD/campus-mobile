import React from 'react'
import { connect } from 'react-redux'

import HomePage from './HomePage'
import { terms } from './mockData/TermMockData.json'

const INITIAL_TERMS = [...terms]

class WebReg extends React.Component {
	constructor(props) {
		super()
	}

	componentWillMount() {
		this.props.populateClassArray()
		this.props.selectCourse(null, null)
	}

	// updateSearch = (search) => {
	// 	this.setState({ search })
	// };

	filterData(text) {
		const { data } = this.props.fullScheduleData
		return data.filter(item => ((item.subject_code + item.course_code).toLowerCase()).includes(text.toLowerCase()))
	}

	render() {
		return <HomePage initialTerms={INITIAL_TERMS} />
	}
}

const mapStateToProps = state => ({
	fullScheduleData: state.schedule.data,
})


const mapDispatchToProps = (dispatch, ownProps) => (
	{
		populateClassArray: () => {
			dispatch({ type: 'POPULATE_CLASS' })
		},
		scheduleLayoutChange: ({ y }) => {
			dispatch({ type: 'SCHEDULE_LAYOUT_CHANGE', y })
		},
		selectCourse: (selectedCourse, data) => {
			dispatch({ type: 'SELECT_COURSE', selectedCourse, data })
		},
	}
)


export default connect(mapStateToProps, mapDispatchToProps)(WebReg)
