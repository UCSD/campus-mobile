import React from 'react'
import { View,	Text, FlatList } from 'react-native'
import Icon from 'react-native-vector-icons/FontAwesome'
import css from '../../styles/css'
import Touchable from '../common/Touchable'

const SearchResultsCard = ({ results, onSelect }) => {
	if (results) {
		return (
			<FlatList
				style={css.ms_container}
				data={results}
				keyExtractor={(listItem, index) => (listItem.title + index)}
				renderItem={
					({ item: rowData, index: rowID }) => (
						<SearchResultsItem
							data={rowData}
							index={rowID}
							onSelect={onSelect}
						/>
					)
				}
			/>
		)
	} else {
		return null
	}
}

const SearchResultsItem = ({ data, onSelect, index }) => (
	<Touchable onPress={() => onSelect(index)}>
		<View style={css.ms_result_row}>
			<Icon name="map-marker" size={22} style={css.ms_result_icon} />
			<Text style={css.ms_result_title}>{data.title}</Text>
			{data.distanceMilesStr ? (
				<Text style={css.ms_result_dist}>{data.distanceMilesStr}</Text>
			) : null }
		</View>
	</Touchable>
)

export default SearchResultsCard
