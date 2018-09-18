import React from 'react'
import { withNavigation } from 'react-navigation'
import ScrollCard from '../common/ScrollCard'
import ParkingOverview from './ParkingOverview'

const ParkingCard = ({
	savedStructures,
	navigation,
	gotoParkingSpotType,
	mySpots,
	lotCount
}) => {
	const extraActions = [
		{
			name: 'Edit Spot Type',
			action: gotoParkingSpotType
		}
	]

<<<<<<< HEAD
  return (
	   <ScrollCard
        id="parking"
        title="Parking Availability"
        renderItem={({ item }) => (
          <ParkingOverview
            structureData={item}
            spotsSelected={mySpots}
            lotCount={lotCount}
          />
        )}
        extraData={mySpots}
        scrollData={savedStructures}
        extraActions={extraActions}
    />
  );
};
=======
	const parkingData = {
		mySpots,
		lotCount,
	}
>>>>>>> a72362899121227600c07243b46af5a55a6e89dd

	return (
		<ScrollCard
			id="parking"
			title="Parking Availability"
			renderItem={({ item }) => (
				<ParkingOverview
					structureData={item}
					spotsSelected={mySpots}
					lotCount={lotCount}
				/>
			)}
			scrollData={savedStructures}
			extraData={parkingData}
			extraActions={extraActions}
		/>
	)
}

export default withNavigation(ParkingCard)
