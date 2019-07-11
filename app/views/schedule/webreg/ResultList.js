import React from 'react'
import { View, Text, FlatList, TouchableOpacity } from 'react-native'
import { withNavigation } from 'react-navigation'
import { connect } from 'react-redux'
import CourseHeader from './CourseCell'
import Data from './mockData/mockData.json'
import NavigationService from '../../../navigation/NavigationService'

class ResultList extends React.Component {
	constructor(props) {
		super(props)

		this.onCoursePressed = this.onCoursePressed.bind(this)
		this.keyExtractor = this.keyExtractor.bind(this)
		this.renderItem = this.renderItem.bind(this)
		this.renderSeparator = this.renderSeparator.bind(this)
	}

	onCoursePressed = () => {
		NavigationService.navigate('CourseView')
	}

	keyExtractor = item => item.courseCode;

	renderItem = ({ item }) => (
		<TouchableOpacity
			onPress={this.onCoursePressed}
		>
			<CourseHeader
				course={item}
				term=""
				style={{ zIndex: 0 }}
			/>
		</TouchableOpacity>
	)

	renderSeparator = () => (<View style={{ height: 15 }} />)

	render() {
		return (
			<FlatList
				data={Data}
				keyExtractor={this.keyExtractor}
				renderItem={this.renderItem}
				ItemSeparatorComponent={this.renderSeparator}
			/>
		)
	}
}

const mapStateToProps = state => ({ input: state.webreg.searchInput })

export default withNavigation(connect(mapStateToProps)(ResultList))
