import React from 'react'
import CourseTableView from './CourseTableView'
import CourseHeader from './CourseHeader'

class CourseView extends React.Component {
	static navigationOptions = ({ navigation }) => ({
		headerLeft: null,
		headerRight: null,
		headerTitle: <CourseHeader  />
	})

	render() {
		return (
			<CourseTableView style={{ marginTop: 16 }} />
		)
	}
}

export default CourseView
