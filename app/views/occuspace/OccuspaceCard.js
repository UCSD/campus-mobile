import React from 'react'
import { View, Text } from 'react-native'
import { withNavigation } from 'react-navigation'
import ScrollCard from '../common/ScrollCard'
import Card from '../common/Card'
import Touchable from '../common/Touchable'
import css from '../../styles/css'
import OccuspaceView from './OccuspaceView'
import { getSelectedOccusapceLocations } from '../../util/occuspace'

const OccupsaceCard = ({
	occuspaceData,
	goToManageLocations,
	selectedLocations,
	requestErrors,
	retry
}) => {
	const extraActions = [
		{
			name: 'Manage Locations',
			action: goToManageLocations
		},
	]
	const retryButton = (
		<Touchable
			style={css.card_button_container}
			onPress={() => retry()}
		>
			<Text style={css.card_button_text}>Try again</Text>
		</Touchable>
	)
	const ManageLocationButton = (
		<Touchable
			style={css.card_button_container}
			onPress={() => goToManageLocations()}
		>
			<Text style={css.card_button_text}>Manage Locations</Text>
		</Touchable>
	)
	// this will handle the case where we ran into an issue with the fetch for occuspace data
	if (requestErrors && requestErrors.GET_OCCUSPACE) {
		return (
			<Card
				id="occuspace"
				title="Busyness"
				extraActions={extraActions}
			>
				<View style={css.occuspace_no_locations_container}>
					<Text style={css.occuspace_no_loocations_text}>Oops. Something went wrong :(</Text>
				</View>
				{retryButton}
			</Card>
		)
	}
	const data = getSelectedOccusapceLocations(occuspaceData, selectedLocations)
	if (selectedLocations.length > 0) {
		return (
			<ScrollCard
				id="occuspace"
				title="Busyness"
				renderItem={({ item }) => (
					<OccuspaceView
						data={item}
					/>
				)}
				extraData={selectedLocations}
				scrollData={data}
				extraActions={extraActions}
				actionButton={ManageLocationButton}
			/>
		)
	} else {
		return (
			<Card
				id="occuspace"
				title="Busyness"
				extraActions={extraActions}
			>
				<View style={css.occuspace_no_locations_container}>
					<Text style={css.occuspace_no_loocations_text}>Add a location to begin.</Text>
				</View>
				{ManageLocationButton}
			</Card>
		)
	}
}

export default withNavigation(OccupsaceCard)
