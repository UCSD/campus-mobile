import React, { Component } from 'react'
import {
	StyleSheet,
	Text,
	View,
	LayoutAnimation,
	PanResponder,
	FlatList,
	TouchableOpacity,
	Dimensions,
	SearchBar,
	TouchableWithoutFeedback,
} from 'react-native'
import { connect } from 'react-redux'

// import { isPointWithinArea, moveArrayElement } from '../../../util/schedule'
// import DragableClassCard from './DragableClassCard'
import CourseListCard from './CourseListCard'
import CourseListMockData from './mockData/CourseListMockData.json'
import { getBottomMargin } from '../../../util/schedule'

class CourseList extends Component {
	componentWillMount() {
		console.log(this)
	}

	render() {
		const mock = CourseListMockData

		console.log(mock)
		return (
			<FlatList
				style={{ marginBottom: getBottomMargin(this.props.device) }}
				// keyboardShouldPersistTaps="handled"
				data={mock.data}
				renderItem={({ item }) => (<CourseListCard
					data={item}
				/>)}
				keyExtractor={item => item.course_code + item.section}
				extraData={this.props.refresh}
			/>
		)
	}
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		paddingHorizontal: 0,
	},
})

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
		changeClassPosition: (draggedClassIndex, anotherClassIndex) => {
			dispatch({ type: 'CHANGE_CLASS_POS', draggedClassIndex, anotherClassIndex })
		},
		refreshClassList: () => {
			dispatch({ type: 'REFRESH_CLASS_LIST' })
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(CourseList)
