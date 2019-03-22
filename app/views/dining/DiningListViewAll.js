import React from 'react'
import { FlatList, View } from 'react-native'
import { connect } from 'react-redux'
import DiningItem from './DiningItem'
import css from '../../styles/css'
import DiningSortBar from './DiningSortBar'

/**
 * DiningListViewAll used by DiningCardContainer
 * @param {Object[]} diningData
 * @return {JSX} Returns presentation JSX DiningListView component
 */
class DiningListViewAll extends React.Component {
	render() {
		const { data } = this.props

		return (
			<FlatList
				style={css.fl_bg}
				contentContainerStyle={css.fl_full}
				data={data}
				keyExtractor={(listItem, index) => {
					if (listItem.id) return listItem.id + index
					else             return listItem.name + index
				}}
				ListHeaderComponent={<DiningSortBar />}
				renderItem={({ item: rowData }) => (<DiningItem data={rowData} />)}
				onViewableItemsChanged={this.onViewableItemsChanged}
				ItemSeparatorComponent={() => (<View style={css.fl_separator} />)}
			/>
		)
	}
}

function mapStateToProps(state) {
	return { data: state.dining.data }
}

export default connect(mapStateToProps)(DiningListViewAll)
