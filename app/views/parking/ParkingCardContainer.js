import React, { Component } from 'react';
import ParkingCard from './ParkingCard';

class ParkingCardContainer extends Component {
  render() {
    return (
      <ParkingCard>
      </ParkingCard>
    );
  }
}

const mapStateToProps = state => ({ parkingData: state.weather.data })
const ActualParkingCard = connect(mapStateToProps)(ParkingCardContainer)
export default ActualParkingCard
