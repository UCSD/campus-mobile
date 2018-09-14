import React, { Component } from 'react';
import { View, Text } from 'react-native';
import { AnimatedCircularProgress } from 'react-native-circular-progress';
import Icon from 'react-native-vector-icons/MaterialIcons';
import ColorConstants from '../../styles/ColorConstants';
import css from '../../styles/css';
import ParkingDetail from './ParkingDetail';

class ParkingOverview extends Component {

    getTotalSpots() {
      const { structureData, spotsSelected, lotCount } = this.props;

      let totalAvailableSpots = 0;
      for(let i = 0; i < spotsSelected.length; i++) {

        const parkingSpotsPerType = structureData['Availability'][spotsSelected[i]];
        for(let j = 0; j < parkingSpotsPerType.length; j++) {

          totalAvailableSpots += Number(parkingSpotsPerType[j]['Open']);

        }
      }
      return totalAvailableSpots;
    };

    renderDetails () {
      const { structureData, spotsSelected, lotCount } = this.props;
      if (spotsSelected.length === 0) {
        return null;
      }
      else if (spotsSelected.length === 1) {
        return (
          <View>
            <ParkingDetail spotType={spotsSelected[0]} spotsAvailable={structureData['Availability'][spotsSelected[0]]['Open']} totalSpots={structureData['Availability'][spotsSelected[0]]['Total']}/>
          </View>
        );
      }
      else if (spotsSelected.length === 2) {
        return (
          <View>
            <ParkingDetail spotType={spotsSelected[0]} />
            <ParkingDetail spotType={spotsSelected[1]} />
          </View>
        );
      }
      else {
        return (
          <View>
            <ParkingDetail spotType={spotsSelected[0]} />
            <ParkingDetail spotType={spotsSelected[1]}  />
            <ParkingDetail spotType={spotsSelected[2]}  />
          </View>
        );
      }
    };

  render() {
    const { structureData, spotsSelected, lotCount } = this.props;
    console.log(this.props)
    return (
      <View>
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
