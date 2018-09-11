import React from 'react';
import { Text } from 'react-native';
import { AnimatedCircularProgress } from 'react-native-circular-progress';
import ScrollCard from '../common/ScrollCard';

const ParkingCard = ({ savedStructures }) => {
  return (
	   <ScrollCard
        id="parking"
        title="Parking Availability"
        renderItem={() => (
          <ParkingOverview />
        )}
        scrollData={savedStructures}
    />
  );
};

export default ParkingCard;
