import React from 'react'
import { FlatList, View } from 'react-native'
import { connect } from 'react-redux'
import DiningItem from './DiningItem'
import css from '../../styles/css'
import COLOR from '../../styles/ColorConstants'
import DiningSortBar from './DiningSortBar'


/**
 * DiningListViewAll used by DiningCardContainer
 * @param {Object[]} diningData
 * @return {JSX} Returns presentation JSX DiningListView component
 */
class DiningListViewAll extends React.Component {
	constructor() {
		super()
		this.onViewableItemsChanged = this.onViewableItemsChanged.bind(this)
		this.viewabilityConfig = {
			itemVisiblePercentThreshold: 25,
			waitForInteraction: true
		}
	}
	state = {
		sortBarVisible: true,
		currentIndex: 0,
	}

	onViewableItemsChanged = (info) => {
		const { viewableItems, changed } = info
		if (viewableItems[0].index < this.state.currentIndex) {
			this.setState({ sortBarVisible: true, currentIndex: viewableItems[0].index })
		} else if (viewableItems[0].index > this.state.currentIndex) {
			this.setState({ sortBarVisible: false, currentIndex: viewableItems[0].index })
		} else if (!changed[0].isViewable) {
			this.setState({ sortBarVisible: true })
		} else if (changed[0].isViewable) {
			this.setState({ sortBarVisible: false })
		}
	}

	render() {
		const { data } = this.props

		if (data) {
			return (
				<View style={css.main_full}>
					<FlatList
						data={data}
						keyExtractor={(listItem, index) => {
							if (listItem.id) return listItem.id + index
							else return listItem.name + index
						}}
						ListHeaderComponent={<DiningSortBar />}
						stickyHeaderIndices={this.state.sortBarVisible ? [0] : null}
						renderItem={({ item: rowData }) => (
							<DiningItem data={rowData} />
						)}
						onViewableItemsChanged={this.onViewableItemsChanged}

						ItemSeparatorComponent={renderSeperator}
						viewabilityConfig={this.viewabilityConfig}
					/>
				</View>
			)
		} else { return null }
	}
}

const renderSeperator = () => (
	<View
		style={{
			height: 1,
			backgroundColor: COLOR.MGREY
		}}
	/>
)

function mapStateToProps(state) {
	return { data: state.dining.data }
}

export default connect(mapStateToProps)(DiningListViewAll)
