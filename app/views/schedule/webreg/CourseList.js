import React, { Component } from 'react'
import {
	FlatList,
} from 'react-native'
import { connect } from 'react-redux'

import CourseListCard from './CourseListCard'
import CourseListMockData from './mockData/CourseListMockData.json'

class CourseList extends Component {
	componentWillMount() {
	}

	render() {
		const mock = CourseListMockData

		return (
			<FlatList
				style={{ marginBottom: 55 }}
				data={mock.data}
				renderItem={({ item }) => (<CourseListCard data={item} />)}
				keyExtractor={item => item.course_code + item.section}
				extraData={this.state}
			/>
		)
	}
}

function mapStateToProps(state) {
	return {
		fullScheduleData: state.schedule.data,
		classes: state.schedule.classes,
		refresh: state.schedule.refresh
	}
}

const mapDispatchToProps = (dispatch, ownProps) => (
	{
		updateClassData: (classes) => {
			dispatch({ type: 'UPDATE_CLASS_DATA', classes })
		},
		refreshClassList: () => {
			dispatch({ type: 'REFRESH_CLASS_LIST' })
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(CourseList)
