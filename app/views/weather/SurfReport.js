import React from 'react'
import {
	View,
	Text,
	ScrollView,
	Image,
	FlatList,
} from 'react-native'
import { connect } from 'react-redux'

import css from '../../styles/css'
import logger from '../../util/logger'

const surfHeader = require('../../assets/images/surf_report_header.jpg')

const mapWeekdays = [
	'Sunday',
	'Monday',
	'Tuesday',
	'Wednesday',
	'Thursday',
	'Friday',
	'Saturday'
]

const mapMonths = [
	'January',
	'February',
	'March',
	'April',
	'May',
	'June',
	'July',
	'August',
	'September',
	'October',
	'November',
	'December'
]

class SurfReport extends React.Component {
	componentDidMount() {
		logger.trackScreen('View Loaded: Surf Report')
	}

	render() {
		try {
			const dateString = new Date(this.props.surfData.spots[0].date)
			return (
				<ScrollView style={css.scroll_default} contentContainerStyle={css.main_full}>
					<Image style={css.sr_headerImage} source={surfHeader} />
					<View style={css.sr_container}>
						<Text style={css.sr_title}>
							Surf Report for {mapWeekdays[dateString.getDay()]}{', '}{mapMonths[dateString.getMonth()]}{' '}{dateString.getDate()}
						</Text>
						<Text style={css.sr_desc}>{this.props.surfData.forecast[3]}</Text>
						<FlatList
							style={css.sr_beach_list}
							data={this.props.surfData.spots}
							keyExtractor={(listItem, index) => (listItem.title + listItem.date + index)}
							renderItem={({ item: rowData }) => (
								<View style={css.sr_surf_row}>
									<Text style={css.sr_beach_name}>{rowData.title}</Text>
									<Text style={css.sr_beach_surf}>{rowData.surf_min}{'-'}{rowData.surf_max}{'ft'}</Text>
								</View>
							)}
						/>
					</View>
				</ScrollView>
			)
		} catch (err) {
			console.log('Error: Surf Report: ', err)
			return (
				<ScrollView style={css.scroll_default} contentContainerStyle={css.main_full}>
					<Image style={css.sr_headerImage} source={surfHeader} />
					<View style={css.sr_container}>
						<Text style={css.sr_desc}>
							An error occurred while loading your Surf Report.
							{'\n'}Please try again later.
						</Text>
					</View>
				</ScrollView>
			)
		}
	}
}

function mapStateToProps(state) {
	return { surfData: state.surf.data }
}

const ActualSurfReport = connect(mapStateToProps)(SurfReport)
export default ActualSurfReport
