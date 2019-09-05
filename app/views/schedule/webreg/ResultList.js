import React from 'react'
import { Text, View, FlatList, TouchableOpacity } from 'react-native'
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
		const { emptyFontStyle, emptyViewStyle } = styles

		if ( this.props.input.length !== 0) {
			return (
				<FlatList
					data={Data}
					keyExtractor={this.keyExtractor}
					renderItem={this.renderItem}
					ItemSeparatorComponent={this.renderSeparator}
				/>
			)
		} else {
			return (
				<View style={emptyViewStyle}>
					<Text style={emptyFontStyle}>Search by course code</Text>
					<Text style={emptyFontStyle}>eg. ANTH 23</Text>
				</View>
			)
		}
	}
}

const styles = {
	emptyViewStyle: {
		flex: 1,
		justifyContent: 'center',
		alignItems: 'center'
	},
	emptyFontStyle: {
		color: 'grey',
		fontSize: 18
	}
}

const mapStateToProps = state => ({ input: state.webreg.searchInput })

export default withNavigation(connect(mapStateToProps)(ResultList))
