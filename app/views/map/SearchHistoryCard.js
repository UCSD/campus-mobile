import React from 'react'
import { View, Text, FlatList } from 'react-native'
import Icon from 'react-native-vector-icons/MaterialIcons'
import css from '../../styles/css'
import Touchable from '../common/Touchable'

const SearchHistoryCard = ({ data, pressHistory, removeHistory }) => (
	<View style={css.shc_list_container}>
		<FlatList
			showsVerticalScrollIndicator={false}
			data={data}
			keyboardShouldPersistTaps="always"
			keyExtractor={(listItem, index) => (String(listItem) + String(index))}
			renderItem={
				({ item: rowData, index: rowID }) => (
					<SearchHistoryItem
						data={rowData}
						index={rowID}
						pressHistory={pressHistory}
						removeHistory={removeHistory}
					/>
				)
			}
		/>
	</View>
)

const SearchHistoryItem = ({ data, index, pressHistory, removeHistory }) => (
	<Touchable onPress={() => { pressHistory(data) }}>
		<View style={css.shc_list_row}>
			<Icon name="history" size={22} style={css.shc_row_icon} />
			<Text style={css.shc_row_text}>{data}</Text>
			<Touchable
				onPress={() => { removeHistory(index) }}
				style={css.shc_row_remove}
			>
				<Icon name="cancel" size={18} style={css.shc_row_icon} />
			</Touchable>
		</View>
	</Touchable>
)

export default SearchHistoryCard
