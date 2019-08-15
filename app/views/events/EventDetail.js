import React from 'react'
import {
	View,
	Text,
	ScrollView,
	Linking,
} from 'react-native'
import Hyperlink from 'react-native-hyperlink'
import moment from 'moment'
import ShareContent from '../common/ShareContent'
import Touchable from '../common/Touchable'
import SafeImage from '../common/SafeImage'
import logger from '../../util/logger'
import general, { openURL } from '../../util/general'
import css from '../../styles/css'

const EventDetail = ({ navigation }) => {
	const { params } = navigation.state
	const { data } = params

	logger.trackScreen('View Loaded: Event Detail: ' + data.title)

	return (
		<ScrollView style={css.scroll_default} contentContainerStyle={css.main_full}>
			{data.imagehq ? (
				<SafeImage
					source={{ uri: data.imagehq }}
					style={css.media_detail_image}
					resizeMode="contain"
				/>
			) : (null)}

			<View style={css.media_detail_container}>
				<Text style={css.media_detail_title}>{data.title}</Text>
				<Text style={css.media_detail_locationText}>
					{data.location}
				</Text>
				<Text style={css.media_detail_dateText}>
					{moment(data.eventdate).format('MMM Do') + ', ' + general.militaryToAMPM(data.starttime) + ' - ' + general.militaryToAMPM(data.endtime)}
				</Text>
				<View style={css.media_detail_descContainer}>
					<Hyperlink
						onPress={(url, text) => openURL(url)}
						linkStyle={(css.hyperlink)}
					>
						<Text style={css.media_detail_descText}>
							{data.description}
						</Text>
					</Hyperlink>
				</View>
				{data.contact_info ? (
					<Touchable
						onPress={() => Linking.openURL('mailto:' + data.contact_info + '?')}
						style={css.button_primary}
					>
						<Text style={css.button_primary_text}>Contact Host</Text>
					</Touchable>
				) : null }
				<ShareContent
					title="Share Event"
					message={'Share event: ' + data.title + '\n' + data.url}
					url={data.url}
				/>
			</View>
		</ScrollView>
	)
}

export default EventDetail
