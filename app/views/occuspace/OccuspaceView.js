import React from 'react'
import { View, Text, FlatList } from 'react-native'
import * as Progress from 'react-native-progress'
import LAYOUT from '../../styles/LayoutConstants'
import ColoredDot from '../common/ColoredDot'
import COLOR from '../../styles/ColorConstants'
import css from '../../styles/css'

const OccuspaceView = ({ data }) => {
	const activeDotColor = data.isOpen ? COLOR.MGREEN : COLOR.MRED

	const statusText = data.isOpen ? 'Open' : 'Closed'
	return (
		<View style={{ flexGrow: 1, padding: 8, width: LAYOUT.MAX_CARD_WIDTH }}>
			<Text style={{ fontSize: 20 }}>
				{data.locationName}
			</Text>
			<View style={{ flexDirection: 'row', paddingBottom: 10 }}>
				<Text>
					{statusText}
				</Text>
				<ColoredDot
					size={10}
					color={activeDotColor}
					style={css.dl_status_icon}
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
		ItemSeparatorComponent={() => <View style={{ paddingBottom: 10 }} />}
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
	console.log(busyness)
	const busynessText = (
		<Text>
			{busyness + '% full'}
		</Text>
	)
	if (units !== 'open seats') {
		return (
			<View>
				{busynessText}
				<Progress.Bar progress={0.3} width={null} />
			</View>
		)
	} else {
		return (
			<View>
				<View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
					{busynessText}
					<Text style={{ fontWeight: 'bold' }}>
						{estimated}
						<Text style={{ fontWeight: 'normal', color: COLOR.DGREY }}>
							{' ' + units}
						</Text>
					</Text>
				</View>
				<Progress.Bar progress={0.3} width={null} />
			</View>
		)
	}
}
export default OccuspaceView
