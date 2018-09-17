import React, { Component } from 'react';
import { View, Text } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons'
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
  	<Icon name="accessible" size={35} color="white" />
  )

  render() {
    const { spotType, spotsAvailable, totalSpots } = this.props;
    const fillAmount = (spotsAvailable/totalSpots) * 100;
  return (
    <View style={{ justifyContent: 'center', alignItems: 'center' }}>
      <AnimatedCircularProgress
        size={150}
        width={15}
        fill={fillAmount ? fillAmount : 0}
        tintColor={this.mapAvailabilityToColor()}
        backgroundColor="#808080"
        rotation={360}
      >
      {
        (fill) => (
          <View style={css.po_fill_info}>
            <Text style={[css.po_circle_number, { color: this.mapAvailabilityToColor() }]}>
              {fillAmount ? Math.trunc(fillAmount) : 0}
            </Text>
            <Text style={[css.po_circle_percent,{ color: this.mapAvailabilityToColor() }]}>
              %
            </Text>
          </View>
        )
      }
      </AnimatedCircularProgress>
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
