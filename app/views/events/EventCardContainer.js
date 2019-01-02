import React from 'react'
import PropTypes from 'prop-types'
import { connect } from 'react-redux'
import moment from 'moment'

import DataListCard from '../common/DataListCard'
import logger from '../../util/logger'
import { militaryToAMPM } from '../../util/general'

export const EventCardContainer = ({ eventsData }) => {
	logger.ga('Card Mounted: Events')

	let data = null
	if (Array.isArray(eventsData)) {
		const parsedEventsData = eventsData.slice()
		parsedEventsData.forEach((element, index) => {
			parsedEventsData[index] = {
				...element,
				subtext: moment(element.eventdate).format('MMM Do') + ', ' + militaryToAMPM(element.starttime) + ' - ' + militaryToAMPM(element.endtime),
				image: element.imagethumb
			}
		})
		data = parsedEventsData
	}
	return (
		<DataListCard
			id="events"
			title="Events"
			data={data}
			item="EventItem"
		/>
	)
}

EventCardContainer.defaultProps = { eventsData: null }

EventCardContainer.propTypes = { eventsData: PropTypes.arrayOf(PropTypes.object) }

const mapStateToProps = state => (
	{ eventsData: state.events.data }
)

export default connect(mapStateToProps)(EventCardContainer)
