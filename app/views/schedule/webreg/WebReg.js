import React from 'react'
import { ScrollView, View, Text, FlatList, Platform, Button } from 'react-native'
import { connect } from 'react-redux'
import { SearchBar } from 'react-native-elements'

import css from '../../../styles/css'
import auth from '../../../util/auth'
import ClassCalendar from './ClassCalendar'

class WebReg extends React.Component {
	constructor(props) {
		super()
		this.state = {
			search: '',
			data: null
		}
	}

	componentWillMount() {
		this.setState({ data: this.props.fullScheduleData.data })
		// this.search.focus()
		this.props.populateClassArray()
	}

	updateSearch = (search) => {
		this.setState({ search })
		this.setState({ data: this.filterData(search) })
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
			<View>
				<ClassCalendar />
			</View>
		)
	}

	// Charles's Render for ClassList
	// render() {
	// 	const { fullScheduleData } = this.props
	// 	const { search } = this.state
	//
	// 	return (
	// 		<ScrollView
	// 			style={css.scroll_default}
	// 			contentContainerStyle={css.main_full}
	// 			onMomentumScrollEnd={(e) => {
	// 				console.log(e.nativeEvent.contentOffset.y)
	// 				this.props.scheduleLayoutChange({ y: e.nativeEvent.contentOffset.y })
	// 				// this.props.clearRefresh();
	// 			}}
	// 			onScrollEndDrag={(e) => {
	// 				console.log(e.nativeEvent.contentOffset.y)
	// 				this.props.scheduleLayoutChange({ y: e.nativeEvent.contentOffset.y })
	// 				// this.props.clearRefresh();
	// 			}}
	// 		>
	//
	// 			<Button onPress={() => auth.retrieveAccessToken().then(credentials => console.log(credentials))} title="Get Access Token" />
	// 			<ClassList />
	// 		</ScrollView>
	// 	)
	// }
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
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(WebReg)
