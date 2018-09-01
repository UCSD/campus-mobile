import React, { Component } from 'react'
import {
	Text,
	View,
	SectionList,
	Switch
} from 'react-native'
import { connect } from 'react-redux'
import css from '../../../styles/css'

const jsonData = require('./Notifications.json')
// this is just an example of dummy data
const data =
	[{
		'id': 0,
		'name': 'Pangea'
	},
	{
		'id': 1,
		'name': 'Gilman'
	},
	{
		'id': 2,
		'name': 'P103'
	}]

class Notifications extends Component {
	constructor(props) {
		super(props)
		this.props = props

		// these for loops take data from the provided json example and set the sate of each slider
		// based on the property called active

		// for (var index in jsonData) {
		// 	for (var i in jsonData[index].data) {
		// 		var active = jsonData[index].data[i].active
		// 		this.changeState(i, active)
		// 	}
		// }
	}

	changeState(index, value) {
		const { isActive, updateSelectedNotifications } = this.props
		const newState = [...isActive]
		newState[index] = value
		updateSelectedNotifications(newState)
	}

	renderRow(item, index, section ) {
		const text = item.name
		const { id }  = item
		return (
			<View style={css.notifications_row_view}>
				<Text style={css.notifications_row_text}>
					{text}
				</Text>
				<View style={css.us_switchContainer}>
					<Switch
						onValueChange={value => this.changeState(id, value)}
						value={this.props.isActive[id]}
					/>
				</View>
			</View>
		)
	}

	render() {
		return (
			<View
				style={css.notifications_full_container}
			>
				<SectionList
					style={css.notifications_section_list}
					renderItem={({ item, index, section }) => this.renderRow(item, index, section)}
					renderSectionHeader={({ section: { title } }) =>
						renderSectionHeader(title)
					}
					sections={jsonData}
					keyExtractor={item => item.id}
					ItemSeparatorComponent={renderSeparator}
					ListFooterComponent={renderSeparator}
					ListHeaderComponent={renderSeparator}
				/>
			</View>
		)
	}
}

const renderSectionHeader = title => (
	<View style={css.notifications_section_list_header_container}>
		<Text style={css.notifications_section_list_header_text}>{title}</Text>
		{renderSeparator}
	</View>
)
const renderSeparator = () => (
	<View
		style={css.notifications_section_list_separator}
	/>
)

const mapStateToProps = state => ({ isActive: state.notifications.isActive })


const mapDispatchToProps = dispatch => (
	{
		updateSelectedNotifications: (isActive) => {
			dispatch({ type: 'SET_NOTIFICATION_STATE', isActive })
		},
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(Notifications)

