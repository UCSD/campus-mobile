import React, { Component } from 'react';
import { connect } from 'react-redux';
import { withNavigation } from 'react-navigation';
import ParkingCard from './ParkingCard';

export class ParkingCardContainer extends Component {
  gotoParkingSpotType = (navigation) => {
		navigation.navigate('ParkingSpotType')
	}

  render() {
    const { navigation, parkingData, count } = this.props;

    const numSpotTypes = () => {
      const { isChecked } = this.props;

      const mySpots = [];
      for (let i = 0; i < isChecked.length; i++) {
        if (isChecked[i]) {
          switch (i) {
            case 0:
              mySpots.push('S');
              break;
            case 1:
              mySpots.push('B');
              break;
            case 2:
              mySpots.push('A');
              break;
            case 3:
              mySpots.push('ADA');
              break;
            default:
              break;
          }
        }
      }
      return mySpots;
    }

    return (
      <ParkingCard
        savedStructures={parkingData}
        gotoParkingSpotType={() => this.gotoParkingSpotType(navigation)}
        mySpots={numSpotTypes()}
        lotCount={count}
      />
    );
  }
}

const mapStateToProps = (state) => {
  return {
    parkingData: state.parking.parkingData,
    isChecked: state.parking.isChecked,
    count: state.parking.count
  }
};

const ActualParkingCard = connect(mapStateToProps)(withNavigation(ParkingCardContainer));
export default ActualParkingCard;
