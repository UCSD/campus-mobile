import React from 'react'
import { FlatList, View } from 'react-native'
import DiningItem from './DiningItem'
import css from '../../styles/css'
import COLOR from '../../styles/ColorConstants'


/**
 * DiningListView used by DiningCardContainer
 * @param {Object[]} data
 * @param {Number} rows Max number of rows
 * @return {JSX} Returns presentation JSX DiningListView component
 */
const DiningListView = ({ data, rows }) => {
	if (data) {
		return (
			<View style={css.scroll_default}>
				<FlatList
					data={(rows) ? (data.slice(0,rows)) : (data)}
					keyExtractor={(listItem, index) => {
						if (listItem.id) return listItem.id + index
						else return listItem.name + index
					}}
					renderItem={({ item: rowData }) => (
						<DiningItem data={rowData} />
					)}
					ItemSeparatorComponent={renderSeperator}
				/>
			</View>
		)
	} else { return null }
}

const renderSeperator = () => (
	<View
		style={{
			height: 1,
			backgroundColor: COLOR.MGREY
		}}
	/>
)

export default DiningListView
