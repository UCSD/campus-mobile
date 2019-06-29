import React from 'react'
import { View } from 'react-native'
import CourseTableView from './CourseTableView'
import CourseDetailView from './CourseDetailView'
import CourseActionView from './CourseActionView'
import CourseHeader from './CourseHeader'
import Course from './mockData/Course.json'

const CourseView = () => (
	<View style={styles.containerStyle}>
		<CourseHeader course={Course} />
		<CourseTableView style={{ marginTop: 16 }} />
		<CourseDetailView course={Course} sectCode="A01" style={{ marginTop: 16 }} />
		<CourseActionView course={Course} sectCode="A01" style={{ marginTop: 16 }} />
	</View>
)

const styles = {
	containerStyle: {
		flex: 1,
		backgroundColor: '#fff'
	}
}

export default CourseView
