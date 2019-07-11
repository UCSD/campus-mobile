import React from 'react'
import { StatusBar } from 'react-native'
import { SafeAreaView } from 'react-navigation'
import CourseDetailView from './CourseDetailView'
import CourseActionView from './CourseActionView'
import CourseHeader from './CourseHeader'

const CourseSectionView = ({ navigation }) => {
	const { course, diCode , leIdx } = navigation.state.params
	return (
		<SafeAreaView style={styles.containerStyle}>
			<StatusBar
				barStyle="dark-content"
			/>
			<CourseHeader course={course} />
			<CourseDetailView course={course} diCode={diCode} leIdx={leIdx} style={{ marginTop: 16 }} />
			{/* <CourseActionView course={course} sectCode="A01" style={{ marginTop: 16 }} /> */}
		</SafeAreaView>
	)
}

const styles = {
	containerStyle: {
		flex: 1,
		backgroundColor: '#fff'
	}
}

export default CourseSectionView