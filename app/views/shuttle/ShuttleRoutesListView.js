import React from 'react'
import { TouchableOpacity, Text, FlatList } from 'react-native'

import Icon from 'react-native-vector-icons/FontAwesome'
import css from '../../styles/css'

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
	<TouchableOpacity
		onPress={() => gotoStopsList(data.stops)}
		style={css.srlv_touchable}
	>
		<Text style={css.srlv_row_name}>
			{data.name.trim()}
		</Text>
		<Icon
			style={css.srlv_icon}
			name="chevron-right"
			size={20}
		/>
	</TouchableOpacity>
)

export default ShuttleRoutesListView
