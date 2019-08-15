import React from 'react'
import { View, Text, ScrollView } from 'react-native'
import { connect } from 'react-redux'
import Icon from 'react-native-vector-icons/Ionicons'
import moment from 'moment'
import Touchable from '../common/Touchable'
import logger from '../../util/logger'
import { gotoNavigationApp, getHumanizedDuration } from '../../util/general'
import css from '../../styles/css'
import COLOR from '../../styles/ColorConstants'

class SpecialEventsDetailView extends React.Component {
	static removeSession(remove, id, title) {
		remove(id)
		logger.trackEvent('Special Events', 'Session Removed: ' + title)
	}

	static addSession(add, id, title) {
		add(id)
		logger.trackEvent('Special Events', 'Session Added: ' + title)
	}

	componentDidMount() {
		const { navigation } = this.props
		const { data } = navigation.state.params

		logger.trackScreen('View Loaded: SpecialEvents Detail: ' + data['talk-title'])
	}

	render() {
		const { navigation, saved } = this.props
		const { data, add, remove } = navigation.state.params

		// Talk Description
		let talkDescription = null
		if (data['full-description'].length > 0) {
			talkDescription = (
				<Text style={css.sedv_sessionDesc}>
					{data['full-description']}
				</Text>
			)
		} else if (data.speakers) {
			talkDescription = (
				data.speakers.map((object, i) => (
					<View style={css.sedv_speakerContainer} key={String(object.name) + String(i)}>
						<Text style={css.sedv_speakerSubTalkTitle}>{object['sub-talk-title']}</Text>
						<Text style={css.sedv_speakerName}>{object.name}</Text>
						<Text style={css.sedv_speakerPosition}>{object.position}</Text>
					</View>
				))
			)
		}

		// Speaker(s) Info
		let speakersInfoElement = null
		if (data['speaker-shortdesc']) {
			speakersInfoElement = (
				<View>
					<Text style={css.sedv_hostedBy}>Hosted By</Text>
					<View style={css.sedv_speakerContainer}>
						<Text style={css.sedv_speakerName}>{data['speaker-shortdesc']}</Text>
					</View>
				</View>
			)
		}

		return (
			<ScrollView style={css.scroll_default} contentContainerStyle={css.main_full}>
				<View style={css.sedv_detailContainer}>
					<View style={css.sedv_starButton}>
						<Touchable onPress={() => (
							isSaved(saved, data.id) ? (
								SpecialEventsDetailView.removeSession(remove, data.id, data['talk-title'])
							) : (
								SpecialEventsDetailView.addSession(add, data.id, data['talk-title'])
							)
						)}
						>
							<View style={css.sedv_starButtonInner}>
								<Icon
									name="ios-star-outline"
									size={32}
									style={css.sedv_starOuterIcon}
								/>
								{ isSaved(saved, data.id)  ? (
									<Icon
										name="ios-star"
										size={26}
										style={css.sedv_starInnerIcon}
									/>
								) : null }
							</View>
						</Touchable>
					</View>

					<View style={css.sedv_labelView}>
						{ data.label ? (
							<Text style={[css.sedv_labelText, { color: data['label-theme'] ? data['label-theme'] : COLOR.BLACK }]}>{data.label}</Text>
						) : null }
						{ data.label || data['talk-type'] === 'Keynote' ? (
							<Text style={css.sedv_labelText}> - </Text>
						) : null }
						<Text style={css.sedv_labelText}>{getHumanizedDuration(data['start-time'], data['end-time'])}</Text>
					</View>

					<Text style={css.sedv_sessionName}>
						{data['talk-title']}
					</Text>
					<Text style={css.sedv_sessionInfo}>
						{data.location} - {moment(Number(data['start-time'])).format('MMM Do YYYY, h:mm a')}
					</Text>

					{talkDescription}

					{(data.directions && data.directions.latitude && data.directions.longitude) ? (
						<Touchable
							underlayColor="rgba(200,200,200,.1)"
							onPress={() => gotoNavigationApp(data.directions.latitude, data.directions.longitude)}
						>
							<View style={css.sedv_sed_dir}>
								<Text style={css.sedv_sed_dir_label}>Directions</Text>
								<Icon name="md-walk" size={32} style={css.sedv_sed_dir_icon} />
							</View>
						</Touchable>
					) : null }
					{speakersInfoElement}
				</View>
			</ScrollView>
		)
	}
}

function isSaved(savedArray, id) {
	if (Array.isArray(savedArray)) {
		for ( let i = 0; i < savedArray.length; ++i) {
			if (savedArray[i] === id) {
				return true
			}
		}
	}
	return false
}

const mapStateToProps = state => ({ saved: state.specialEvents.saved })
const ActualSpecialEventsDetailView = connect(mapStateToProps)(SpecialEventsDetailView)
export default ActualSpecialEventsDetailView
