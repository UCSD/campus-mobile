import React from 'react'
import { View } from 'react-native'
import { withNavigation } from 'react-navigation'
import { connect } from 'react-redux'
import ResultList from './ResultList'
import CourseRes from './mockData/CourseSearch.json'

class CourseSearch extends React.Component {
	componentDidMount = () => {
		this.props.updateFilterStatus(false)
		this.props.updateFilterVal([false, false, false])
	}

	render() {
		return (
			<View flex style={{ backgroundColor: 'white' }}>
				<ResultList data={CourseRes} />
			</View>
		)
	}
}

const mapStateToProps = state => ({
})

const mapDispatchToProps = dispatch => (
	{
		updateFilterVal: (filterVal) => {
			dispatch({
				type: 'UPDATE_FILTER',
				filterVal
			})
		},
		updateFilterStatus: (filterVisible) => {
			dispatch({ type: 'CHANGE_FILTER_VISIBILITY', filterVisible })
		},
	}
)

export default withNavigation(connect(mapStateToProps, mapDispatchToProps)(CourseSearch))
