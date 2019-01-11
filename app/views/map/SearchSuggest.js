import React from 'react'
import {
	View,
	Text,
	FlatList,
	TouchableOpacity
} from 'react-native'
import MaterialIcon from 'react-native-vector-icons/MaterialIcons'
import css from '../../styles/css'

const suggestions = [
	{
		name: 'Parking',
		icon: 'local-parking',
	},
	{
		name: 'Hydration',
		icon: 'local-drink',
	},
	{
		name: 'Mail',
		icon: 'local-post-office',
	},
	{
		name: 'ATM',
		icon: 'local-atm',
	},
]

const SearchSuggest = ({ onPress }) => (
	<View style={css.ss_card_main}>
		<View style={css.ss_list_container}>
			<SearchSuggestList
				historyData={suggestions}
				onPress={onPress}
			/>
		</View>
	</View>
)

const SearchSuggestList = ({ historyData, onPress }) => (
	<FlatList
		showsVerticalScrollIndicator={false}
		showsHorizontalScrollIndicator={false}
		data={historyData}
		horizontal={true}
		keyboardShouldPersistTaps="always"
		keyExtractor={(listItem, index) => (listItem.name + index)}
		renderItem={
			({ item: rowData }) => (
				<SearchSuggestItem
					data={rowData}
					onPress={onPress}
				/>
			)
		}
	/>
)

const SearchSuggestItem = ({ data, onPress }) => (
	<TouchableOpacity
		underlayColor="rgba(200,200,200,.1)"
		onPress={() => {
			onPress(data.name)
		}}
	>
		<View style={css.ss_list_row}>
			<View style={css.ss_icon_container}>
				<MaterialIcon
					name={data.icon}
					size={24}
					color="white"
				/>
			</View>
			<Text style={css.ss_icon_label}>
				{data.name}
			</Text>
		</View>
	</TouchableOpacity>
)

export default SearchSuggest
