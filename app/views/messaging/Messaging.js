import React, { Component } from 'react'
import {
	View,
	Text,
	ScrollView,
	FlatList,
	RefreshControl,
} from 'react-native'
import { connect } from 'react-redux'
import moment from 'moment'
import Icon from 'react-native-vector-icons/MaterialIcons'
import logger from '../../util/logger'
import css from '../../styles/css'

const checkData = (data) => {
	if (!Array.isArray(data)) return null
	const cleanData = data.filter((item) => {
		const day = moment.unix(item.timestamp)
		if (day.isValid()) {
			return true
		}
		return false
	})
	cleanData.sort( ( left, right ) => moment.utc(right.timestamp).diff(moment.utc(left.timestamp)))
	return cleanData
}

export class Messaging extends Component {
	static navigationOptions = { title: 'Notifications' }

	componentDidMount() {
		logger.ga('View Loaded: Messaging')
	}

	renderSeparator = ({ leadingItem }) => (
		<View
			style={{ height: 1, width: '100%', backgroundColor: '#D2D2D2' }}
		/>
	)

	renderItem = ({ item }) => {
		const { message, timestamp } = item
		const { message: messageText, title } = message
		const day = moment(timestamp)

		return (
			<View style={{ height: 110, width: '100%', flexDirection: 'row', justifyContent: 'flex-start' }}>
				<View style={{ justifyContent: 'center', alignItems: 'center', marginLeft: 10, marginRight: 20 }}>
					<Icon
						name="check-circle"
						size={30}
						style={{ color: '#21D383' }}
					/>
				</View>
				<View  style={{ flexDirection: 'column', justifyContent: 'center' }}>
					<Text style={{ color: '#D2D2D2' }}>{day.format('MMMM Do')}</Text>
					<Text style={{ color: '#D2D2D2' }}>{title}</Text>
					<Text style={{ color: '#D2D2D2' }}>{messageText}</Text>
				</View>
			</View>
		)
	}

	render() {
		const { messages, nextTimestamp } = this.props.messages

		const filteredData = checkData(messages)

		let isLoading = false
		if (this.props.myMessagesStatus) isLoading = true

		const MessageRefresh = (
			<RefreshControl
				refreshing={isLoading}
				onRefresh={() => this.props.updateMessages(new Date().getTime())}
			/>
		)

		return (
			<ScrollView
				style={css.scroll_default}
				contentContainerStyle={css.main_full}
				refreshControl={MessageRefresh}
			>
				<FlatList
					style={{ backgroundColor: '#F9F9F9' }}
					data={filteredData}
					renderItem={this.renderItem}
					keyExtractor={(item, index) => item.id}
					ItemSeparatorComponent={this.renderSeparator}
				/>

			</ScrollView>
		)
	}
}

const mapStateToProps = (state, props) => (
	{
		messages: state.messages,
		myMessagesStatus: state.requestStatuses.GET_MESSAGES,
		myMessagesError: state.requestErrors.GET_MESSAGES
	}
)

const mapDispatchToProps = (dispatch, ownProps) => (
	{
		updateMessages: (timestamp) => {
			dispatch({ type: 'UPDATE_MESSAGES', timestamp })
		},
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(Messaging)
