import React from 'react'
import { connect } from 'react-redux'

import DataListCard from '../common/DataListCard'
import general from '../../util/general'

export const QuicklinksCardContainer = ({ linksData }) => (
	<DataListCard
		id="quicklinks"
		title="Links"
		data={linksData}
		rows={4}
		item="QuicklinksItem"
		cardSort={general.dynamicSort('card-order')}
	/>
)

const mapStateToProps = state => (
	{ linksData: state.links.data }
)

const ActualLinksCard = connect(mapStateToProps)(QuicklinksCardContainer)

export default ActualLinksCard
