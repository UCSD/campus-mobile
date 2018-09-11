import React, { Component } from 'react';
import { connect } from 'react-redux';
import { AnimatedCircularProgress } from 'react-native-circular-progress';
import ParkingCard from './ParkingCard';

export class ParkingCardContainer extends Component {
  render() {
    return (
      <ParkingCard
        savedStructures={}
      />
    );
  }
}

const mapStateToProps = state => ({ savedStructures:  });
const ActualParkingCard = connect(mapStateToProps)(ParkingCardContainer)
export default ActualParkingCard;
