import React, { Component } from 'react'
import {
	Text,
	View,
	SectionList,
	Switch,
	LayoutAnimation,
	TouchableWithoutFeedback
} from 'react-native'
import { connect } from 'react-redux'
import DatePicker from 'react-native-datepicker'
import css from '../../../styles/css'

class Notifications extends Component {
	componentDidMount() {
		this.props.getTopics()
	}

	getSections() {
		if (!Array.isArray(this.props.topics)) return []

		const sections = [
			{
				'title': 'Topics',
				'data': []
			}
		]

		const userProfile = this.props.profile
		const { classifications } = userProfile

		this.props.topics.forEach((audience) => {
			if (audience.audienceId !== 'all'
				&& this.props.isLoggedIn
				&& classifications
				&& Array.isArray(Object.keys(classifications))
				&& Object.keys(classifications).indexOf(audience.audienceId) >= 0
				&& classifications[audience.audienceId]) {
				sections[0].data = [...sections[0].data, ...audience.topics]
			}
			else if (audience.audienceId === 'all') {
				sections[0].data = [...sections[0].data, ...audience.topics]
			}
		})

		return sections
	}

	setSubscription = (topicId, value) => {
		if (value === true) {
			this.props.subscribeToTopic(topicId)
		} else {
			this.props.unsubscribeFromTopic(topicId)
		}
	}

	renderSectionHeader = title => (
		<View style={css.pnt_header_row}>
			<Text style={css.pnt_header_text}>{title}</Text>
		</View>
	)

	renderItem(item, index, section) {
		const { topicId, topicMetadata } = item
		const { name } = topicMetadata

		let topicState = false
		if (this.props.profile
			&& Array.isArray(this.props.profile.subscribedTopics)
			&& this.props.profile.subscribedTopics.indexOf(topicId) >= 0) {
			topicState = true
		}

		return (
			<View style={css.pnt_row}>
				<Text style={css.pnt_row_text} numberOfLines={2}>
					{name}
				</Text>
				<View style={css.pnt_switch}>
					<Switch
						onValueChange={value => this.setSubscription(topicId, value)}
						value={topicState}
					/>
				</View>
			</View>
		)
	}

	render() {
		const sections = this.getSections()

		return (
			<View style={css.main_full_flex}>
				<SectionList
					renderItem={({ item, index, section }) => this.renderItem(item, index, section)}
					renderSectionHeader={({ section: { title } }) => this.renderSectionHeader(title)}
					sections={sections}
					keyExtractor={item => item.id}
					stickySectionHeadersEnabled={false}
				/>
			</View>
		)
	}
}


const mapStateToProps = state => ({
	isLoggedIn: state.user.isLoggedIn,
	profile: state.user.profile,
	topics: state.messages.topics,
	topicsLoading: state.requestStatuses.GET_TOPICS,
})

const mapDispatchToProps = dispatch => (
	{
		getTopics: () => {
			dispatch({ type: 'GET_TOPICS' })
		},
		subscribeToTopic: (topicId) => {
			dispatch({ type: 'SUBSCRIBE_TO_TOPIC', topicId })
		},
		unsubscribeFromTopic: (topicId) => {
			dispatch({ type: 'UNSUBSCRIBE_FROM_TOPIC', topicId })
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(Notifications)
