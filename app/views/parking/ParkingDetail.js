import React, { Component } from 'react';
import { View, Text } from 'react-native';
import { AnimatedCircularProgress } from 'react-native-circular-progress';
import ColorConstants from '../../styles/ColorConstants';
import css from '../../styles/css';

class ParkingDetail extends Component {

   mapSpotToColor() {
     const { spotType } = this.props;
    switch (spotType) {
      case 'A':
        return ColorConstants.MRED;
      case 'B':
        return ColorConstants.GREEN;
      case 'S':
        return ColorConstants.YELLOW
      case 'ADA':
        return ColorConstants.MBLUE;
      default:
        return null;
    }
  }

  mapSpotToLetterColor() {

    const { spotType } = this.props;
    switch (spotType) {
      case 'S':
        return ColorConstants.BLACK;
      default:
        return ColorConstants.WHITE;
    }
  }

  mapAvailabilityToColor()  {
    const { spotsAvailable, totalSpots } = this.props;

    const percentAvailable = spotsAvailable / totalSpots;
    if (percentAvailable > 0.5) {
      return ColorConstants.AVAILABILITY_HIGH;
    }
    else if (percentAvailable >= 0.25 && percentAvailable < 0.5) {
      return ColorConstants.AVAILABILITY_MEDIUM;
    }
    else {
      return ColorConstants.AVAILABILITY_LOW;
    }
  }

  accessibleIcon = () => (
  	<Icon name="accessible" size={25} color="white" />
  )

  render() {
    const { spotType, spotsAvailable, totalSpots } = this.props;
  return (
    <View>
      <AnimatedCircularProgress
        size={150}
        width={15}
        fill={(spotsAvailable/totalSpots)*100}
        tintColor={this.mapAvailabilityToColor()}
        backgroundColor="#808080"
        rotation={360}
      />
      <View style={[css.po_circle,{ backgroundColor: this.mapSpotToColor() }]}>
        <Text style={[css.po_character, { color: this.mapSpotToLetterColor() }]}>
          {this.mapSpotToColor() === ColorConstants.MBLUE ? this.accessibleIcon() : spotType}
        </Text>
      </View>
    </View>
  );
}
}

export default ParkingDetail;
