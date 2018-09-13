import React from 'react';
import { Text } from 'react-native';
import { withNavigation } from 'react-navigation'
import { AnimatedCircularProgress } from 'react-native-circular-progress';
import ScrollCard from '../common/ScrollCard';

const ParkingCard = ({ savedStructures, navigation, gotoParkingSpotType }) => {
  const extraActions = [
		{
			name: 'Edit parking spot type',
			action: gotoParkingSpotType
		}
	];
  
  return (
	   <ScrollCard
        id="parking"
        title="Parking Availability"
        renderItem={() => (
          <ParkingOverview />
        )}
        scrollData={savedStructures}
        extraActions={extraActions}
    />
  );
};

export default withNavigation(ParkingCard);
