import React from 'react'
import { TouchableOpacity, Text, FlatList } from 'react-native'

import Icon from 'react-native-vector-icons/FontAwesome'
import css from '../../styles/css'

const ShuttleStopsListView = ({ navigation }) => {
	const { shuttle_stops, addStop } = navigation.state.params
	return (
		<FlatList
			style={css.main_full}
			data={shuttle_stops}
			keyExtractor={(listItem, index) => (String(listItem.id) + String(index))}
			renderItem={
				({ item: rowData }) => (
					<StopItem
						data={rowData}
						addStop={addStop}
					/>
				)
			}
		/>
	)
}

const StopItem = ({ data, addStop }) => (
	<TouchableOpacity
		onPress={() => addStop(data.id, data.name.trim())}
		style={css.sslv_list_row}
		disabled={(data.saved === true)}
	>
		<Text style={(data.saved === true) ? (css.sslv_row_name_disabled) : (css.sslv_row_name)}>
			{data.name.trim()}
		</Text>
		<Icon
			style={css.sslv_icon}
			name="chevron-right"
			size={20}
		/>
	</TouchableOpacity>
)

export default ShuttleStopsListView
