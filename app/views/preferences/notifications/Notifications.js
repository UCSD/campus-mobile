import React, { Component } from 'react'
import {
	Text,
	View,
	FlatList,
	Switch
} from 'react-native'
import { connect } from 'react-redux'
import css from '../../../styles/css'

// this is just an example of dummy data
const data = [
	{
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
	}

	changeState(index, value) {
		const { isActive, updateSelectedNotifications } = this.props
		const newState = [...isActive]
		newState[index] = value
		updateSelectedNotifications(newState)
	}

	renderRow(item) {
		const { name } = item.item
		return (
			<View
				style={css.notifications_row_view}
			>
				<Text
					style={css.pst_row_text}
				>
					{name}
				</Text>
				<View style={css.us_switchContainer}>
					<Switch
						onValueChange={value => this.changeState(item.index, value)}
						value={this.props.isActive[item.index]}
					/>
				</View>
			</View>
		)
	}

	render() {
		return (
			<View
				style={css.pst_full_container}
			>
				<FlatList
					style={css.pst_flat_list}
					scrollEnabled={true}
					showsVerticalScrollIndicator={false}
					keyExtractor={dataItem => dataItem.id}
					data={data}
					extraData={this.props.isActive}
					renderItem={item => this.renderRow(item)}
					enableEmptySections={true}
					ItemSeparatorComponent={renderSeparator}
				/>
			</View>
		)
	}
}

const renderSeparator = () => (
	<View
		style={css.pst_flat_list_separator}
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

