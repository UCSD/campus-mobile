import React from 'react'
import { connect } from 'react-redux'
import SpecialEventsCard from './SpecialEventsCard'

export const SpecialEventsCardContainer = ({ specialEventsData, saved, hideCard }) => {
	if (specialEventsData) {
		return (
			<SpecialEventsCard
				title="Events"
				specialEvents={specialEventsData}
				saved={saved}
				hideCard={hideCard}
			/>
		)
	} else {
		return null
	}
}

const mapStateToProps = state => (
	{
		specialEventsData: state.specialEvents.data,
		saved: state.specialEvents.saved
	}
)

const mapDispatchToProps = dispatch => (
	{
		hideCard: (id) => {
			dispatch({ type: 'UPDATE_CARD_STATE', id, state: false })
		}
	}
)

const ActualSpecialEventsCard = connect(mapStateToProps, mapDispatchToProps)(SpecialEventsCardContainer)
export default ActualSpecialEventsCard
