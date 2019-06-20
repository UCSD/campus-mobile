
import React, { Component } from 'react'
import { connect } from 'react-redux'
import { withNavigation } from 'react-navigation'
import OccuspaceCard from './OccuspaceCard'

class OccuspaceCardContainer extends Component {
	navigateToManageLocations = (navigation) => {
		navigation.navigate('ManageOccuspaceLocations')
	}

	render() {
		const {
			navigation,
			occuspaceData,
			selectedLocations,
		} = this.props
		return (
			<OccuspaceCard
				occuspaceData={occuspaceData}
				goToManageLocations={() => this.navigateToManageLocations(navigation)}
				selectedLocations={selectedLocations}
			/>
		)
	}
}

const mapStateToProps = state => (
	{
		occuspaceData: state.occuspace.data,
		selectedLocations: state.occuspace.selectedLocations
	}
)

export default connect(mapStateToProps)(withNavigation(OccuspaceCardContainer))
