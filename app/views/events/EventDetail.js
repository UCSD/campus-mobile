import React from 'react'
import {
	View,
	Text,
	ScrollView,
	Linking,
} from 'react-native'
import moment from 'moment'

import ShareContent from '../common/ShareContent'
import Touchable from '../common/Touchable'
import SafeImage from '../common/SafeImage'
import logger from '../../util/logger'
import general from '../../util/general'
import css from '../../styles/css'

const EventDetail = ({ navigation }) => {
	const { params } = navigation.state
	const { data } = params

	logger.ga('View Loaded: Event Detail: ' + data.title)

	return (
		<ScrollView style={css.scroll_default} contentContainerStyle={css.main_full}>
			{data.imagehq ? (
				<SafeImage
					source={{ uri: data.imagehq }}
					style={css.media_detail_image}
					resizeMode="stretch"
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
				<Text style={css.media_detail_descText}>
					{data.description}
				</Text>
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
