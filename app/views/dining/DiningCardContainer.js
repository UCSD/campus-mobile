import React from 'react'
import { connect } from 'react-redux'
import DataListCard from '../common/DataListCard'

export const DiningCardContainer = ({ diningData }) => (
	<DataListCard
		id="dining"
		title="Dining"
		data={diningData}
		item="DiningItem"
	/>
)

function mapStateToProps(state) {
	return { diningData: state.dining.data }
}

const ActualDiningCard = connect(mapStateToProps)(DiningCardContainer)

export default ActualDiningCard
