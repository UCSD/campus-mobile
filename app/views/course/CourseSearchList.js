import React from 'react'
import { View } from 'react-native'
import { withNavigation } from 'react-navigation'
import { connect } from 'react-redux';
import ResultList from './ResultList';
import SearchHeader from './SearchHeader';
import Filter from './Filter'


class CourseSearchList extends React.Component {
	

	render() {
		return (
			<View flex style={{ backgroundColor: 'white' }}>
				<SearchHeader />
				<ResultList />
				{this.props.showFilter && <Filter />}
			</View>
		)
	}
}

const mapStateToProps = (state) => {
	return { showFilter: state.course.filterVisible}
}

export default withNavigation( connect(mapStateToProps)(CourseSearchList));