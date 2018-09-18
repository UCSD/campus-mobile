import React, { Component } from 'react';
import { View, Text } from 'react-native';
import { AnimatedCircularProgress } from 'react-native-circular-progress';
import Icon from 'react-native-vector-icons/MaterialIcons';
import ColorConstants from '../../styles/ColorConstants';
import css from '../../styles/css';
import ParkingDetail from './ParkingDetail';
import LAYOUT from '../../styles/LayoutConstants';

class ParkingOverview extends Component {

    getTotalSpots() {
      const { structureData, spotsSelected } = this.props;

      let totalAvailableSpots = 0;
      for(let i = 0; i < spotsSelected.length; i++){

        const parkingSpotsPerType = structureData['Availability'][spotsSelected[i]];
        if(parkingSpotsPerType){
          for(let j = 0; j < parkingSpotsPerType.length; j++) {
            totalAvailableSpots += Number(parkingSpotsPerType[j]['Open']);
          }
        }
      }
      return totalAvailableSpots;
    };

    getOpenPerType(currentType) {
      const { structureData } = this.props;

      const tempType = structureData['Availability'][currentType];
      let openPerType = 0;
      if(tempType){
        for(let i = 0; i < tempType.length; i++){
          openPerType += Number(tempType[i]['Open']);
        }
      }
      return openPerType;
    }

    getTotalPerType(currentType) {
      const { structureData } = this.props;

      const tempType = structureData['Availability'][currentType];
      let totalPerType = 0;
      if(tempType){
        for(let i = 0; i < tempType.length; i++){
          totalPerType += Number(tempType[i]['Total']);
        }
      }
      return totalPerType;
    }

    renderDetails() {
      const { structureData, spotsSelected } = this.props;
      if (spotsSelected.length === 0) {
        return null;
      }
      else if (spotsSelected.length === 1) {
        return (
          <View style={css.po_one_spot_selected}>
            <ParkingDetail spotType={spotsSelected[0]} spotsAvailable={ this.getOpenPerType(spotsSelected[0]) } totalSpots={ this.getTotalPerType(spotsSelected[0]) } size={LAYOUT.MAX_CARD_WIDTH * 0.38} widthMultiplier={15}/>
          </View>
        );
      }
      else if (spotsSelected.length === 2) {
        return (
          <View style={css.po_two_spots_selected}>
            <ParkingDetail spotType={spotsSelected[0]} spotsAvailable={ this.getOpenPerType(spotsSelected[0]) } totalSpots={ this.getTotalPerType(spotsSelected[0])} size={LAYOUT.MAX_CARD_WIDTH * 0.32} widthMultiplier={LAYOUT.MAX_CARD_WIDTH * 0.035}/>
            <ParkingDetail spotType={spotsSelected[1]} spotsAvailable={ this.getOpenPerType(spotsSelected[1]) } totalSpots={ this.getTotalPerType(spotsSelected[1]) } size={LAYOUT.MAX_CARD_WIDTH * 0.32} widthMultiplier={LAYOUT.MAX_CARD_WIDTH * 0.035}/>
          </View>
        );
      }
      else {
        return (
          <View style={css.po_three_spots_selected}>
            <ParkingDetail spotType={spotsSelected[0]} spotsAvailable={ this.getOpenPerType(spotsSelected[0]) } totalSpots={ this.getTotalPerType(spotsSelected[0]) } size={LAYOUT.MAX_CARD_WIDTH * 0.25} widthMultiplier={LAYOUT.MAX_CARD_WIDTH * 0.028}/>
            <ParkingDetail spotType={spotsSelected[1]}  spotsAvailable={ this.getOpenPerType(spotsSelected[1]) } totalSpots={ this.getTotalPerType(spotsSelected[1]) } size={LAYOUT.MAX_CARD_WIDTH * 0.25} widthMultiplier={LAYOUT.MAX_CARD_WIDTH * 0.028}/>
            <ParkingDetail spotType={spotsSelected[2]}  spotsAvailable={ this.getOpenPerType(spotsSelected[2]) } totalSpots={ this.getTotalPerType(spotsSelected[2]) } size={LAYOUT.MAX_CARD_WIDTH * 0.25} widthMultiplier={LAYOUT.MAX_CARD_WIDTH * 0.028}/>
          </View>
        );
      }
    };

  render() {
    const { structureData, spotsSelected } = this.props;
    return (
      <View style={{ flex: 1, justifyContent: 'space-evenly' }}>
        <Text style={css.po_structure_name}>
          {structureData.LocationName}
        </Text>
        <Text style={css.po_structure_spots_available}>
          ~ {this.getTotalSpots()} Spots
        </Text>
        {this.renderDetails()}
      </View>
    );
  };
}

export default ParkingOverview;
