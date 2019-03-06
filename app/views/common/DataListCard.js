import React from 'react'
import { View, Text, ActivityIndicator } from 'react-native'
import { withNavigation } from 'react-navigation'
import DataListView from './DataListView'
import Card from '../common/Card'
import Touchable from './Touchable'
import css from '../../styles/css'

/**
 * @param  {String} title Card header
 * @param {Object[]} data contains data for row items
 * @param {String} item String name for row item: pass string here instead of component
 * @param {Number} rows number of rows to display on card
 * @param {Function} cardSort array sorting function
 * @return {JSX} Generic component for list type cards
 */
export const DataListCard = ({ navigation, id, title, data, item, rows, cardSort }) => {
	let sortedData = data
	if (cardSort && sortedData) {
		sortedData = sortedData.slice().sort(cardSort)
	}

	return (
		<Card id={id} title={title}>
			<View style={css.dlc_list}>
				{data ? (
					<View>
						<DataListView
							data={sortedData}
							rows={rows}
							scrollEnabled={false}
							item={item}
							card={false}
						/>
						<Touchable onPress={() => (navigation.navigate('DataListViewAll', { title, data, item }))}>
							<View style={css.card_button_container}>
								<Text style={css.card_button_text}>View All</Text>
							</View>
						</Touchable>
					</View>
				) : (
					<View style={[css.dlc_cardcenter, css.dlc_wc_loading_height]}>
						<ActivityIndicator size="large" />
					</View>
				)}
			</View>
		</Card>
	)
}

DataListCard.defaultProps = {
	rows: 3
}

export default withNavigation(DataListCard)
