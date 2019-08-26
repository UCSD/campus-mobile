import React from 'react'
import { StatusBar } from 'react-native'
import { SafeAreaView } from 'react-navigation'
import CourseTableView from './CourseTableView'
import CourseHeader from './CourseHeader'
import Course from './mockData/Course.json'

const CourseView = () => (
	<SafeAreaView style={styles.containerStyle}>
		<StatusBar
			barStyle="dark-content"
		/>
		<CourseHeader course={Course} />
		<CourseTableView style={{ marginTop: 16 }} />
	</SafeAreaView>
)

const styles = {
	containerStyle: {
		flex: 1,
		backgroundColor: '#fff'
	}
}

export default CourseView
