import React, { Component } from 'react'
import { View, Text, FlatList, ActivityIndicator } from 'react-native'
import { connect } from 'react-redux'
import Hyperlink from 'react-native-hyperlink'
import moment from 'moment'
import Icon from 'react-native-vector-icons/MaterialIcons'
import logger from '../../util/logger'
import css from '../../styles/css'
import { openURL } from '../../util/general'
import { DGREY } from '../../styles/ColorConstants'

const checkData = (data) => {
	if (!Array.isArray(data)) return null
	const cleanData = data.filter((item) => {
		const day = moment.unix(item.timestamp)
		if (day.isValid()) {
			return true
		}
		return false
	})
	return cleanData
}

export class Messaging extends Component {
	componentDidMount() {
		logger.trackScreen('View Loaded: Messaging')
		this.props.updateMessages(new Date().getTime())
		this.props.navigation.addListener('willFocus', () => {
			const { unreadMessages } = this.props.messages
			if (unreadMessages > 0) {
				this.props.notificationsSeen()
			}
		})
	}

	renderItem = ({ item }) => {
		const { message, timestamp } = item
		const { message: messageText, title } = message
		const day = moment(timestamp)

		let timeString
		if (day.isSame(moment(), 'day')) {
			timeString = day.format('h:mm a')
		} else {
			timeString = day.fromNow()
		}

		return (
			<View style={css.notifications_row}>
				<View style={css.notifications_vector_icon}>
					<Icon
						name="info"
						size={30}
						style={{ color: DGREY }}
					/>
				</View>
				<View style={{ flexDirection: 'column', justifyContent: 'center', flex: 1 }}>
					<Text style={css.notifications_timestamp_text}>{timeString}</Text>
					<Text style={css.notifications_title_text}>{title}</Text>
					<View style={css.notifications_body_text_container}>
						<Hyperlink
							onPress={(url, text) => openURL(url)}
							linkStyle={(css.hyperlink)}
						>
							<Text style={css.notifications_body_text}>{messageText}</Text>
						</Hyperlink>
					</View>
				</View>
			</View>
		)
	}

	render() {
		const { messages, nextTimestamp, unreadMessages } = this.props.messages
		const { updateMessages } = this.props
		const filteredData = checkData(messages)

		const isLoading = (this.props.myMessagesStatus != null)
		if (!isLoading && unreadMessages && this.props.navigation.isFocused()) {
			this.props.notificationsSeen()
		}

		let myMessagesStatusText = ''
		if (isLoading) {
			myMessagesStatusText = 'Loading your notifications, please wait.'
		} else if (this.props.myMessagesError) {
			myMessagesStatusText = 'There was a problem fetching your messages.\n\n' +
								   'Please try again soon.'
		} else if (messages && messages.length === 0) {
			myMessagesStatusText = 'You have no notifications.\nYou may be opted out of all topics.\n\n' +
								   'Notifications to specific topics can be turned on in User Profile.'
		}

		return (
			<FlatList
				data={filteredData}
				ListEmptyComponent={
					<Text style={css.notifications_status}>
						{myMessagesStatusText}
					</Text>
				}
				style={css.scroll_default}
				contentContainerStyle={css.main_full}
				onRefresh={() => updateMessages(new Date().getTime())}
				refreshing={isLoading}
				renderItem={this.renderItem}
				keyExtractor={(item, index) => item.messageId}
				onEndReachedThreshold={0.5}
				ListFooterComponent={(isLoading && nextTimestamp) ? <ActivityIndicator size="large" animating /> : null}
				onEndReached={(info) => {
					// this if check makes sure that we dont fetch extra data in the intialization of the list
					if (info.distanceFromEnd > 0
						&& nextTimestamp
						&& !isLoading) {
						updateMessages(nextTimestamp)
					}
				}}
			/>
		)
	}
}

const mapStateToProps = (state, props) => (
	{
		messages: state.messages,
		myMessagesStatus: state.requestStatuses.GET_MESSAGES,
		myMessagesError: state.requestErrors.GET_MESSAGES,
		unreadMessages: state.unreadMessages
	}
)

const mapDispatchToProps = (dispatch, ownProps) => (
	{
		updateMessages: (timestamp) => {
			dispatch({ type: 'UPDATE_MESSAGES', timestamp })
		},
		notificationsSeen: () => {
			const timestamp = new Date().getTime()
			const profileItems = { latestTimeStamp: timestamp }
			dispatch({ type: 'MODIFY_LOCAL_PROFILE', profileItems })
			dispatch({ type: 'SET_UNREAD_MESSAGES',  count: 0 })
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(Messaging)
