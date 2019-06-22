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

import { isPointWithinArea, moveArrayElement } from '../../../util/schedule'
import DragableClassCard from './DragableClassCard'
import CourseListCard from './CourseListCard';

class CourseList extends Component {
	// static defaultProps = {
	// 	animationDuration: 250
	// };

	state = {
		dndEnabled: true,
		refresh: false
	};

	// componentWillMount() {
	// 	this.panResponder = this.createPanResponder()
	// }

	// componentWillUpdate() {
	// 	LayoutAnimation.configureNext({
	// 		...LayoutAnimation.Presets.easeInEaseOut,
	// 		duration: this.props.animationDuration
	// 	})
	// }

	// onMoveShouldSetPanResponder = (gestureState) => {
	// 	const { dx, dy, moveX, moveY, numberActiveTouches } = gestureState

	// 	if (numberActiveTouches !== 1) {
	// 		return false
	// 	}

	// 	if (dx === 0 && dy === 0) {
	// 		return false
	// 	}

	// 	const targetClass = this.findClassAtCoordinates(moveX, moveY)
	// 	if (targetClass) {
	// 		this.classBeingDragged = targetClass
	// 		console.log('class that will be dragged', targetClass)

	// 		return true
	// 	}

	// 	return false
	// };

	// onPanResponderGrant = () => {
	// 	this.updateClassState(this.classBeingDragged, { isBeingDragged: true })
	// };

	// onPanResponderMove = (gestureState) => {
	// 	const { moveX, moveY } = gestureState

	// 	console.log('drag and drop', this.state.dndEnabled)
	// 	if (!this.state.dndEnabled) {
	// 		return
	// 	}

	// 	const draggedOverClass = this.findClassAtCoordinates(moveX, moveY, this.classBeingDragged)

	// 	if (draggedOverClass) {
	// 		this.swapClasses(this.classBeingDragged, draggedOverClass)
	// 		console.log('found dest class', draggedOverClass)
	// 	}
	// };

	// onPanResponderEnd = () => {
	// 	this.updateClassState(this.classBeingDragged, { isBeingDragged: false })
	// 	this.classBeingDragged = undefined
	// };

	// onRenderClass = (item, screenX, screenY, width, height) => {
	// 	this.updateClassState(item, {
	// 		tlX: screenX,
	// 		tlY: screenY,
	// 		brX: screenX + width,
	// 		brY: screenY + height,
	// 	})
	// };

	// findClassAtCoordinates = (x, y, exceptClass) => {
	// 	const res = this.props.classes.find(item => item.tlX && item.tlY && item.brX && item.brY
	// 		&& isPointWithinArea(x, y, item.tlX, item.tlY, item.brX, item.brY)
	// 		&& (!exceptClass || exceptClass.sectionID !== item.sectionID))

	// 	return res
	// };


	// swapClasses = (draggedClass, anotherClass) => {
	// 	const newClasses = [...this.props.classes]

	// 	const draggedClassIndex = this.props.classes.findIndex(({ sectionID }) => sectionID === draggedClass.sectionID)
	// 	const anotherClassIndex = this.props.classes.findIndex(({ sectionID }) => sectionID === anotherClass.sectionID)

	// 	// swap(newClasses[draggedClassIndex], newClasses[anotherClassIndex], 'tlX')
	// 	// swap(newClasses[draggedClassIndex], newClasses[anotherClassIndex], 'tlY')
	// 	// swap(newClasses[draggedClassIndex], newClasses[anotherClassIndex], 'brX')
	// 	// swap(newClasses[draggedClassIndex], newClasses[anotherClassIndex], 'brY')

	// 	let larger,
	// 		smaller
	// 	if (draggedClassIndex > anotherClassIndex) {
	// 		larger = draggedClassIndex
	// 		smaller = anotherClassIndex
	// 	} else {
	// 		smaller = draggedClassIndex
	// 		larger = anotherClassIndex
	// 	}

	// 	this.props.changeClassPosition(draggedClassIndex, anotherClassIndex)
	// 	// TODO: SOLVE the problem that LayoutAnimation never starts
	// 	// LayoutAnimation.configureNext({
	// 	// 	...LayoutAnimation.Presets.spring,
	// 	// 	duration: this.props.animationDuration
	// 	// })
	// 	this.setState({ refresh: !this.state.refresh })

	// 	this.setState(state => ({
	// 		dndEnabled: false,
	// 	}), this.enableDndAfterAnimating)
	// };

	// updateClassState = (item, props) => {
	// 	const index = this.props.classes.findIndex(({ sectionID }) => sectionID === item.sectionID)
	// 	this.props.updateClassData([
	// 		...this.props.classes.slice(0, index),
	// 		{
	// 			...this.props.classes[index],
	// 			...props,
	// 		},
	// 		...this.props.classes.slice(index + 1)
	// 	])
	// }

	// enableDnd = () => {
	// 	this.setState({ dndEnabled: true })
	// };

	// enableDndAfterAnimating = () => {
	// 	setTimeout(this.enableDnd, this.props.animationDuration)
	// };

	// createPanResponder = (): PanResponder => PanResponder.create({
	// 	onMoveShouldSetPanResponder: (_, gestureState) => this.onMoveShouldSetPanResponder(gestureState),
	// 	onPanResponderGrant: (_, gestureState) => this.onPanResponderGrant(),
	// 	onPanResponderMove: (_, gestureState) => this.onPanResponderMove(gestureState),
	// 	onPanResponderRelease: (_, gestureState) => this.onPanResponderEnd(),
	// 	onPanResponderTerminate: (_, gestureState) => this.onPanResponderEnd(),
	// });

	render() {
		const { mock } = this.props

		console.log(mock)
		return (
			// <View
			// 	style={styles.container}
			// 	{...this.panResponder.panHandlers}
			// >

			<FlatList
				// keyboardShouldPersistTaps="handled"
				data={mock.data}
				renderItem={({ item }) => (<CourseListCard
					data={item}
				/>)}
				keyExtractor={item => item.course_code + item.section}
				extraData={this.props.refresh}
			/>

			// </View>
		)
	}
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		paddingHorizontal: 0,
	},
})

// function swap(sourceObj, targetObj, key) {
// 	const temp = sourceObj[key]
// 	sourceObj[key] = targetObj[key]
// 	targetObj[key] = temp
// }

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
