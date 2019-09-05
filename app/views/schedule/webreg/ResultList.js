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

	filterCheck = (data) => {
		const { filterVal } = this.props
		return (!filterVal[0] && parseInt(data.CRSE_CODE) < 100) ||
			(!filterVal[1] && parseInt(data.CRSE_CODE) >= 100 && parseInt(data.CRSE_CODE) < 200) ||
			(!filterVal[2] && parseInt(data.CRSE_CODE) >= 200)
	}

	inputCheck = (data) => {
		const firstDigit = this.props.input.match(/\d/)
		const splitIndex = this.props.input.indexOf(firstDigit)
		let subject = ''
		let code = ''
		if (splitIndex !== -1) {
			subject = this.props.input.substring(0, splitIndex).trim()
			code = this.props.input.substring(splitIndex).trim()
		} else {
			subject = this.props.input.trim()
		}
		return (!subject || data.SUBJ_CODE.includes(subject.toUpperCase())) && (!code || data.CRSE_CODE.includes(code))
	}

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
		// TODO - Mock Filter Behavior. Need modification with real data
		const renderedData = []
		for (let i = 0; i < data.length; i++) {
			if (this.filterCheck(data[i]) && this.inputCheck(data[i])) {
				renderedData.push(data[i])
			}
		}
		// TODO - End Mock Filter

		const { emptyFontStyle, emptyViewStyle, searchHeader, searchHeaderFont } = styles
		const header = (
			<View style={searchHeader}>
				<Text style={searchHeaderFont}>Found {renderedData.length} courses matching &quot;{this.props.input}&quot;</Text>
			</View>
		)

		if (this.props.input.length !== 0) {
			return (
				<FlatList
					data={renderedData}
					keyExtractor={this.keyExtractor}
					ListHeaderComponent={header}
					renderItem={this.renderItem}
					extraData={this.state}
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

const mapStateToProps = state => ({
	input: state.webreg.searchInput,
	filterVal: state.webreg.filterVal
})

export default withNavigation(connect(mapStateToProps)(ResultList))
