import React from 'react'
import { Text, FlatList } from 'react-native'
import Ionicons from 'react-native-vector-icons/Ionicons'
import css from '../../styles/css'
import Touchable from '../common/Touchable'

const ShuttleRoutesListView = ({ navigation }) => {
	const { shuttle_routes, gotoStopsList } = navigation.state.params
	return (
		<FlatList
			style={css.main_full}
			data={shuttle_routes}
			keyExtractor={(listItem, index) => (String(listItem.id) + String(index))}
			renderItem={
				({ item: rowData }) => (
					<RouteItem
						data={rowData}
						gotoStopsList={gotoStopsList}
					/>
				)
			}
		/>
	)
}

const RouteItem = ({ data, gotoStopsList }) => (
	<Touchable
		onPress={() => gotoStopsList(data.stops)}
		style={css.fl_row}
	>
		<Text style={css.fl_row_title}>
			{data.name.trim()}
		</Text>
		<Ionicons name="ios-arrow-forward" size={28} style={css.fl_row_arrow} />
	</Touchable>
)

export default ShuttleRoutesListView
