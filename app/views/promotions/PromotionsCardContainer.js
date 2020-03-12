import React from 'react'
import { connect } from 'react-redux'
import PromotionsCard from './PromotionsCard'

export const PromotionsCardContainer = ({ promotionsData, hideCard }) => {
	if (promotionsData) {
		return (
			<PromotionsCard
				title="Promotions"
				promoFeed={promotionsData}
				hideCard={hideCard}
			/>
		)
	} else {
		return null
	}
}

const mapStateToProps = state => (
	{
		promotionsData: state.promotions.data,
	}
)

const mapDispatchToProps = dispatch => (
	{
		hideCard: (id) => {
			dispatch({ type: 'UPDATE_CARD_STATE', id, state: false })
		}
	}
)

const ActualPromotionsCard = connect(mapStateToProps, mapDispatchToProps)(PromotionsCardContainer)
export default ActualPromotionsCard
