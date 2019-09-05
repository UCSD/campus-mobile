import React from 'react'
import { Text, View, FlatList, TouchableOpacity } from 'react-native'
import { withNavigation } from 'react-navigation'
import { connect } from 'react-redux'
import CourseCell from './CourseCell'
import NavigationService from '../../../navigation/NavigationService'

class ResultList extends React.Component {
	onCoursePressed = (index) => {
		NavigationService.navigate('CourseView')
	}

	keyExtractor = item => item.courseCode;

	renderItem = ({ item, index }) => (
		<TouchableOpacity
			onPress={() => this.onCoursePressed(index)}
		>
			<CourseCell
				course={item}
				term=""
				style={{ zIndex: 0 }}
			/>
		</TouchableOpacity>
	)

	render() {
		const { data } = this.props
		const { emptyFontStyle, emptyViewStyle, searchHeader, searchHeaderFont } = styles
		const header = (
			<View style={searchHeader}>
				<Text style={searchHeaderFont}>Found {data.length} courses matching &quot;{this.props.input}&quot;</Text>
			</View>
		)

		if (this.props.input.length !== 0) {
			return (
				<FlatList
					data={data}
					keyExtractor={this.keyExtractor}
					ListHeaderComponent={header}
					renderItem={this.renderItem}
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
		color: '#7D7D7D',
		fontSize: 18
	},
	searchHeader: {
		height: 40,
		display: 'flex',
		paddingHorizontal: '6%',
		borderBottomWidth: 1,
		borderColor: '#EAEAEA',
	},
	searchHeaderFont: {
		fontSize: 14,
		lineHeight: 40,
	}
}

const mapStateToProps = state => ({ input: state.webreg.searchInput })

export default withNavigation(connect(mapStateToProps)(ResultList))
