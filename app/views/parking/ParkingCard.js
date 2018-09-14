import React from 'react';
import { Text } from 'react-native';
import { withNavigation } from 'react-navigation'
import { AnimatedCircularProgress } from 'react-native-circular-progress';
import ScrollCard from '../common/ScrollCard';
import ParkingOverview from './ParkingOverview';

const ParkingCard = ({ savedStructures, navigation, gotoParkingSpotType, mySpots, lotCount }) => {
  const extraActions = [
		{
			name: 'Edit Parking Spot Type',
			action: gotoParkingSpotType
		}
	];

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
        extraActions={extraActions}
    />
  );
};

export default withNavigation(ParkingCard);
