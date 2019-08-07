import React from 'react'
import { Text, FlatList } from 'react-native'
import Ionicons from 'react-native-vector-icons/Ionicons'
import css from '../../styles/css'
import Touchable from '../common/Touchable'

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
	<Touchable
		onPress={() => addStop(data.id, data.name.trim())}
		style={css.fl_row}
		disabled={(data.saved === true)}
	>
		<Text style={(data.saved === true) ? (css.fl_row_title_disabled) : (css.fl_row_title)}>
			{data.name.trim()}
		</Text>
		<Ionicons name="ios-arrow-forward" size={28} style={css.fl_row_arrow} />
	</Touchable>
)

export default ShuttleStopsListView
