import React from 'react'
import { View, Text, FlatList } from 'react-native'
import * as Progress from 'react-native-progress'
import ColoredDot from '../common/ColoredDot'
import COLOR from '../../styles/ColorConstants'
import css from '../../styles/css'

const OccuspaceView = ({ data }) => {
	const activeDotColor = data.isOpen ? COLOR.MGREEN : COLOR.MRED

	const statusText = data.isOpen ? 'Open' : 'Closed'
	return (
		<View style={css.occuspace_view}>
			<Text style={css.occuspace_location_title}>
				{data.locationName}
			</Text>
			<View style={css.occuspace_status_text}>
				<Text>
					{statusText}
				</Text>
				<ColoredDot
					size={10}
					color={activeDotColor}
					style={css.occusapce_status_dot}
				/>
			</View>
			<OccuspaceSubViewList data={data.sublocations.length > 0 ? data.sublocations : [data]} />
		</View>
	)
}

const OccuspaceSubViewList = ({ data }) => (
	<FlatList
		style={[css.scroll_default]}
		data={data}
		scrollEnabled={true}
		keyExtractor={listItem => listItem.locationId.toString()}
		renderItem={({ item: rowData }) => <OccuspaceRow data={rowData} />}
		ItemSeparatorComponent={() => <View style={css.occusapce_item_separator} />}
	/>
)

const OccuspaceRow = ({ data }) => {
	const { locationName, busyness, estimated, units } = data
	return (
		<View>
			<Text>
				{locationName}
			</Text>
			<BuysnessInfo busyness={busyness} estimated={estimated} units={units} />
		</View>
	)
}
const BuysnessInfo = ({ busyness, estimated, units }) => {
	const percentage = 1 - (busyness / 100)
	const percentageText = Math.round(percentage * 100)
	const color = (busyness <= 50 ? COLOR.GREEN : COLOR.YELLOW)
	const busynessText = (
		<Text style={css.occuspace_busyness_text}>
			{percentageText + '% availability'}
		</Text>
	)
	if (units !== 'open seats') {
		return (
			<View>
				<View style={css.occuspace_busyness_row}>
					{busynessText}
				</View>
				<Progress.Bar
					progress={percentage}
					width={null}
					color={color}
					borderWidth={0}
					unfilledColor={COLOR.MGREY}
				/>
			</View>
		)
	} else {
		return (
			<View>
				<View style={css.occuspace_busyness_row}>
					{busynessText}
					<Text style={css.occuspace_estimated_text}>
						{estimated}
						<Text style={css.occusapce_units_text}>
							{' ' + units}
						</Text>
					</Text>
				</View>
				<Progress.Bar
					progress={percentage}
					width={null}
					color={color}
					borderWidth={0}
					unfilledColor={COLOR.MGREY}
				/>
			</View>
		)
	}
}
export default OccuspaceView
