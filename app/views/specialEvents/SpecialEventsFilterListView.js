import React, { Component } from 'react'
import { connect } from 'react-redux'
import { ScrollView } from 'react-native'

import css from '../../styles/css'
import logger from '../../util/logger'
import MultiSelect from './MultiSelect'

class SpecialEventsMyScheduleView extends Component {
	componentDidMount() {
		logger.ga('View Loaded: SpecialEventsFilterListView')
	}

	handleFilterSelect = (labels) => {
		this.props.updateSpecialEventsLabels(labels)
	}

	render() {
		return (
			<MultiSelect
				items={this.props.specialEventsLabels}
				themes={this.props.specialEventsLabelThemes}
				selected={this.props.labels}
				onSelect={this.handleFilterSelect}
				applyFilters={() => {
					this.props.navigation.pop()
				}}
			/>
		)
	}
}

const mapStateToProps = state => (
	{
		specialEventsTitle: (state.specialEvents.data) ? state.specialEvents.data.name : '',
		specialEventsLabels: state.specialEvents.data.labels,
		specialEventsLabelThemes: state.specialEvents.data['label-themes'],
		labels: state.specialEvents.labels,
	}
)

const mapDispatchToProps = dispatch => (
	{
		updateSpecialEventsLabels: (labels) => {
			dispatch({ type: 'UPDATE_SPECIAL_EVENTS_LABELS', labels })
		},
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(SpecialEventsMyScheduleView)
