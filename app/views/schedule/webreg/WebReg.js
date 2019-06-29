import React from 'react'
import { ScrollView, View, Text, FlatList, Platform, Button } from 'react-native'
import { connect } from 'react-redux'

import css from '../../../styles/css'
import auth from '../../../util/auth'
import HomePage from './HomePage'
import CourseListCard from './CourseListCard'

class WebReg extends React.Component {
	constructor(props) {
		super()
		this.state = {
			search: '',
		}
	}

	componentWillMount() {
		this.props.populateClassArray()
		this.props.selectCourse(null, null)
	}

	updateSearch = (search) => {
		this.setState({ search })
	};

	filterData(text) {
		const { data } = this.props.fullScheduleData
		return data.filter(item => ((item.subject_code + item.course_code).toLowerCase()).includes(text.toLowerCase()))
	}

	render() {
		return (
			<HomePage />
		)
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
