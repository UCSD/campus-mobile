import React from 'react'
import { SafeAreaView } from 'react-navigation'
import CourseTableView from './CourseTableView'
import CourseHeader from './CourseHeader'
import Data from './mockData/CourseSearchResult.json'

class CourseView extends React.Component {
	static navigationOptions = ({ navigation }) => ({
		headerLeft: null,
		headerRight: null,
		headerTitle: <CourseHeader course={Data} />
	})

	render() {
		return (
			<SafeAreaView style={styles.containerStyle}>
				<CourseTableView data={Data.GROUP} style={{ marginTop: 16 }} />
			</SafeAreaView>
		)
	}
}

const styles = {
	containerStyle: {
		flex: 1,
		backgroundColor: '#fff'
	}
}

export default CourseView
