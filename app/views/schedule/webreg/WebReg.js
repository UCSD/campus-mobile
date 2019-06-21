import React from 'react'
import { ScrollView, View, Text, FlatList, Platform, Button } from 'react-native'
import { connect } from 'react-redux'
import { SearchBar } from 'react-native-elements'

import css from '../../../styles/css'
import auth from '../../../util/auth'
import HomePage from './HomePage'
import ClassCard from './ClassCard'

class WebReg extends React.Component {
	constructor(props) {
		super()
		this.state = {
			search: '',
			// data: null
		}
	}

	componentWillMount() {
		// this.setState({ data: this.props.fullScheduleData.data })
		// this.search.focus()
		this.props.populateClassArray()
		this.props.selectCourse(null, null)
	}

	updateSearch = (search) => {
		this.setState({ search })
		// this.setState({ data: this.filterData(search) })
	};

	filterData(text) {
		const { data } = this.props.fullScheduleData
		return data.filter(item => ((item.subject_code + item.course_code).toLowerCase()).includes(text.toLowerCase()))
	}

	renderClasses() {
		return (
			<FlatList
				ListHeaderComponent={(
					<SearchBar
						ref={search => this.search = search}
						placeholder="Search Course"
						onChangeText={this.updateSearch}
						value={this.state.search}
						platform={Platform.OS}
						onCancel={() => console.log('hahaa')}
						autoCorrect={false}
					/>
				)}
				keyboardShouldPersistTaps="handled"
				data={this.state.data}
				showsVerticalScrollIndicator={false}
				renderItem={({ item }) => <ClassCard data={item} props={this.props} />}
				keyExtractor={item => item.course_code + item.section}
			/>
		)
	}

	render() {
		return (
			<HomePage />
		)
	}
}

function mapStateToProps(state) {
	return {
		fullScheduleData: state.schedule.data,
	}
}


const mapDispatchToProps = (dispatch, ownProps) => (
	{
		populateClassArray: () => {
			dispatch({ type: 'POPULATE_CLASS' })
		},
		scheduleLayoutChange: ({ y }) => {
			dispatch({ type: 'SCHEDULE_LAYOUT_CHANGE', y })
		},
		selectCourse: (selectedCourse, data) => {
			dispatch({ type: 'SELECT_COURSE', selectedCourse, data })
		},
	}
)


export default connect(mapStateToProps, mapDispatchToProps)(WebReg)
