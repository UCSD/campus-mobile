import React, { Component } from 'react'
import {
	View,
	Text,
	FlatList,
	ActivityIndicator
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
		this.props.updateMessages(new Date().getTime())
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
					<Text style={{ color: '#a1a1a1', fontWeight: 'bold', fontSize: 10 }}>{day.format('MMMM Do')}</Text>
					<Text style={{ color: '#818181', fontWeight: 'bold', fontSize: 28 }}>{title}</Text>
					<Text style={{ color: '#818181', fontWeight: 'bold', fontSize: 14 }}>{messageText}</Text>
				</View>
			</View>
		)
	}

	render() {
		const { messages, nextTimestamp, loadingMoreData } = this.props.messages
		const { updateMessages, loadMoreMessages } = this.props
		const filteredData = checkData(messages)

		let isLoading = false
		if (this.props.myMessagesStatus) isLoading = true

		return (
			<View style={css.main_full}>
				<FlatList
					style={{ backgroundColor: '#f1f1f1' }}
					data={filteredData}
					onRefresh={() => updateMessages(new Date().getTime())}
					refreshing={isLoading}
					renderItem={this.renderItem}
					keyExtractor={(item, index) => item.id}
					ItemSeparatorComponent={this.renderSeparator}
					onEndReachedThreshold={0.5}
					ListFooterComponent={loadingMoreData ? <ActivityIndicator size="large" animating /> : null}
					onEndReached={(info) => {
						// this if check makes sure that we dont fetch extra data in the intialization of the list
						if (info.distanceFromEnd > 0 && nextTimestamp) {
							loadMoreMessages(nextTimestamp)
						}
					}}
				/>
			</View>
		)
	}
}

const mapStateToProps = (state, props) => (
	{
		messages: state.messages,
		myMessagesStatus: state.requestStatuses.GET_MESSAGES,
		myMessagesError: state.requestErrors.GET_MESSAGES,
		loadingMoreData: state.loadingMoreData
	}
)

const mapDispatchToProps = (dispatch, ownProps) => (
	{
		updateMessages: (timestamp) => {
			dispatch({ type: 'UPDATE_MESSAGES', timestamp })
		},
		loadMoreMessages: (timestamp) => {
			dispatch({ type: 'LOAD_MORE_MESSAGES', timestamp })
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(Messaging)
