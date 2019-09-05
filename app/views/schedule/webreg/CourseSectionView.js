import React from 'react'
import { SafeAreaView } from 'react-navigation'
import CourseDetailView from './CourseDetailView'
import CourseActionView from './CourseActionView'
import CourseHeader from './CourseHeader'
import CourseCalender from './ClassCalendar'
import Data from './mockData/CourseSearchResult.json'

class CourseSectionView extends React.Component {
	static navigationOptions = ({ navigation }) => ({
		headerLeft: null,
		headerRight: null,
		headerTitle: <CourseHeader course={Data} />
	})

	render() {
		const { course, index } = this.props.navigation.state.params
		return (
			<SafeAreaView style={styles.containerStyle}>
				<CourseDetailView course={course} diIndex={index} />
				<CourseCalender />
				<CourseActionView style={{ position: 'absolute', bottom: 22 }} />
			</SafeAreaView>
		)
	}
}

const styles = {
	containerStyle: {
		flex: 1,
		backgroundColor: '#fff',
		paddingTop: 15,
	}
}

export default CourseSectionView
