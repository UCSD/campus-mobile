import React from 'react'
import { View, Text, FlatList } from 'react-native'

import { getMinutesETA } from '../../util/shuttle'
import css from '../../styles/css'

const ShuttleSmallList = ({ arrivalData, rows, scrollEnabled }) => (
	<View style={css.ssl_listContainer}>
		<Text style={css.ssl_nextText}>
			Next Arrivals
		</Text>
		{ arrivalData ? (
			<FlatList
				style={{ height: getRowHeight(rows) }}
				scrollEnabled={scrollEnabled}
				showsVerticalScrollIndicator={false}
				keyExtractor={(listItem, index) => (
					listItem.route.id +
					listItem.vehicle.id.toString() +
					index
				)}
				data={arrivalData}
				renderItem={
					({ item: rowData }) => (
						<ShuttleSmallRow
							arrival={rowData}
						/>
					)
				}
				enableEmptySections={true}
			/>
		) : null }
	</View>
)

const ShuttleSmallRow = ({ arrival }) => (
	<View style={css.ssl_rowContainer}>
		<View style={[css.ssl_circle, { backgroundColor: arrival.route.color }]}>
			<Text
				style={css.ssl_shortNameText}
				allowFontScaling={false}
			>
				{arrival.route.shortName}
			</Text>
		</View>
		<Text
			style={css.ssl_nameText}
			numberOfLines={2}
		>
			{arrival.route.name}
		</Text>
		<Text style={css.ssl_etaText}>{getMinutesETA(arrival.secondsToArrival)}</Text>
	</View>
)

function getRowHeight(rows) {
	const rowHeight = 40
	const padding = 8
	return rows * (rowHeight + padding)
}

export default ShuttleSmallList
