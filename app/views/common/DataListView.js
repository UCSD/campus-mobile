import React from 'react'
import { FlatList, ScrollView } from 'react-native'
import EventItem from '../events/EventItem'
import NewsItem from '../news/NewsItem'
import DiningItem from '../dining/DiningItem'
import QuicklinksItem from '../quicklinks/QuicklinksItem'
import css from '../../styles/css'

/**
 * Generic listview used by DataListCard
 * @param {Object[]} data
 * @param {Number} rows Max number of rows
 * @param {Boolean} scrollEnabled
 * @param {String} item String name of row item
 * @param {Boolean} card Display rows with card styling (if available);
 * @return {JSX} Returns presentation JSX DataListView component
 */
const DataListView = ({ style, data, rows, scrollEnabled, item, card }) => {
	if (rows) {
		return (
			<DataFlatList
				style={style}
				data={data}
				rows={rows}
				item={item}
				card={card}
			/>
		)
	} else {
		return (
			<ScrollView style={css.scroll_default} contentContainerStyle={css.main_full}>
				<DataFlatList
					style={style}
					data={data}
					rows={rows}
					item={item}
					card={card}
				/>
			</ScrollView>
		)
	}
}

const DataFlatList = ({ style, data, rows, item, card }) => (
	<FlatList
		style={style}
		data={(rows) ? (data.slice(0,rows)) : (data)}
		keyExtractor={(listItem, index) => {
			// Specify the unique key that each kind of
			// item will use to identify itself. Each
			// item MUST have a unique key!
			switch (item) {
				case 'EventItem': {
					return listItem.id + index
				}
				case 'NewsItem': {
					return listItem.title + index
				}
				case 'DiningItem': {
					if (listItem.id) return listItem.id + index
					else return listItem.name + index
				}
				case 'QuicklinksItem': {
					return listItem.name + index
				}
				default: {
					return index
				}
			}
		}}
		renderItem={({ item: rowData }) => {
			// Add to switch statement as new Items are needed
			// Only reason this is a switch is cuz Actions from react-router-flux doesn't like being passed JSX
			// Should revisit to see if this can be simplified
			switch (item) {
				case 'EventItem': {
					return (<EventItem data={rowData} card={card} />)
				}
				case 'NewsItem': {
					return (<NewsItem data={rowData} card={card} />)
				}
				case 'DiningItem': {
					return (<DiningItem data={rowData} card={card} />)
				}
				case 'QuicklinksItem': {
					return (<QuicklinksItem data={rowData} card={card} />)
				}
				default: {
					return null
				}
			}
		}}
	/>
)

export default DataListView
