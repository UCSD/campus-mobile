import React, { Component } from 'react';
import { View, Text } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons'
import { AnimatedCircularProgress } from 'react-native-circular-progress';
import ColorConstants from '../../styles/ColorConstants';
import css from '../../styles/css';
import LAYOUT from '../../styles/LayoutConstants';



class ParkingDetail extends Component {

   mapSpotToColor() {
     const { spotType } = this.props;
    switch (spotType) {
      case 'A':
        return ColorConstants.MRED;
      case 'B':
        return ColorConstants.MGREEN;
      case 'S':
        return ColorConstants.YELLOW;
      case 'V':
        return ColorConstants.BLACK;
      case 'Accessible':
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

  mapSpotsToDisplay() {
    const { spotsAvailable, totalSpots, progressNumber, progressPercent } = this.props;
    const fillAmount = (spotsAvailable/totalSpots) * 100;

    if(spotsAvailable === 0) {
      return (
        <View style={css.po_fill_info}>
          <Text style={[ css.po_circle_number, { color: ColorConstants.DGREY }, { fontSize: progressNumber }]}>
            NA
          </Text>
        </View>
      )
    }
    else {
      return (
        <View style={css.po_fill_info}>
          <Text style={[css.po_circle_number, { color: this.mapAvailabilityToColor() }, { fontSize: progressNumber }]}>
            {fillAmount ? Math.trunc(fillAmount) : 0}
          </Text>
          <Text style={[css.po_circle_percent,{ color: this.mapAvailabilityToColor() }, { fontSize: progressPercent }]}>
            %
          </Text>
        </View>
      )
    }
  }

  accessibleIcon = () => (
  	<Icon name="accessible" size={35} color="white" />
  )

  render() {
    const {
      spotType,
      spotsAvailable,
      totalSpots,
      size ,
      widthMultiplier,
      circleRadius,
      letterSize,
      progressNumber,
      progressPercent
    } = this.props;
    const fillAmount = (spotsAvailable/totalSpots) * 100;

  return (
    <View style={{ alignItems: 'center' }}>
      <AnimatedCircularProgress
        duration={1500}
        size={size}
        width={widthMultiplier}
        fill={fillAmount ? fillAmount : 0}
        tintColor={this.mapAvailabilityToColor()}
        backgroundColor={ColorConstants.LGREY2}
        rotation={360}
        style={{ marginBottom: 15 }}
      >
	{
        (fill) => (
          <View>
            {this.mapSpotsToDisplay()}
          </View>
        )
      }
      </AnimatedCircularProgress>
      <View style={[css.po_circle,{ backgroundColor: this.mapSpotToColor() },{ borderRadius: circleRadius, width: (circleRadius*2), height: (circleRadius*2) }]}>
        <Text style={[css.po_character, { color: this.mapSpotToLetterColor() }, { fontSize: letterSize }]}>
          {this.mapSpotToColor() === ColorConstants.MBLUE ? this.accessibleIcon() : spotType}
        </Text>
      </View>
    </View>
  );
}
}

export default ParkingDetail;
