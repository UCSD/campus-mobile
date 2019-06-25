
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
			requestErrors,
			retry
		} = this.props
		return (
			<OccuspaceCard
				occuspaceData={occuspaceData}
				goToManageLocations={() => this.navigateToManageLocations(navigation)}
				selectedLocations={selectedLocations}
				requestErrors={requestErrors}
				retry={retry}
			/>
		)
	}
}

const mapStateToProps = state => (
	{
		occuspaceData: state.occuspace.data,
		selectedLocations: state.occuspace.selectedLocations,
		requestErrors: state.requestErrors
	}
)

function mapDispatchtoProps(dispatch) {
	return {
		retry: () => {
			dispatch({ type: 'UPDATE_OCCUSPACE_DATA' })
		}
	}
}

export default connect(mapStateToProps, mapDispatchtoProps)(withNavigation(OccuspaceCardContainer))
