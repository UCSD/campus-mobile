import React, { Component } from 'react';
import { View, Text } from 'react-native';
import { AnimatedCircularProgress } from 'react-native-circular-progress';

class ParkingOverview extends Component {
  render() {
    return (
      <View>
        <Text>P406 Lot</Text>
        <Text>~15 Spots</Text>
        <AnimatedCircularProgress
          size={120}
          width={15}
          fill={100}
          tintColor="#00e0ff"
          onAnimationComplete={() => console.log('onAnimationComplete')}
          backgroundColor="#3d5875" />
      </View>

    );
  }
}

export default ParkingOverview;
