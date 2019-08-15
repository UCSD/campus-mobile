import React from 'react'
import {
	View,
	Text,
	ScrollView,
	Linking,
} from 'react-native'
import moment from 'moment'
import Hyperlink from 'react-native-hyperlink'
import { withNavigation } from 'react-navigation'

import { openURL } from '../../util/general'
import ShareContent from '../common/ShareContent'
import SafeImage from '../common/SafeImage'
import logger from '../../util/logger'
import Touchable from '../common/Touchable'
import css from '../../styles/css'

const NewsDetail = ({ navigation }) => {
	const { params } = navigation.state
	const { data } = params

	logger.trackScreen('View Loaded: News Detail: ' + data.title)

	return (
		<ScrollView style={css.scroll_default} contentContainerStyle={css.main_full}>
			{data.image_lg ? (
				<SafeImage
					source={{ uri: data.image_lg }}
					style={css.media_detail_image}
					resizeMode="contain"
				/>
			) : null }

			<View style={css.media_detail_container}>
				<Text style={css.media_detail_title}>{data.title}</Text>
				<Text style={css.media_detail_dateText}>
					{moment(css.media_detail_date).format('MMM Do, YYYY')}
				</Text>
				<View style={css.media_detail_descContainer}>
					<Hyperlink
						onPress={(url, text) => openURL(url)}
						linkStyle={(css.hyperlink)}
					>
						<Text style={css.media_detail_descText}>
							{data.description.trim()}
						</Text>
					</Hyperlink>
				</View>
				{data.link ? (
					<Touchable
						onPress={() => Linking.openURL(data.link)}
						style={css.button_primary}
					>
						<Text style={css.button_primary_text}>Read More</Text>
					</Touchable>
				) : null }
				<ShareContent
					title="Share Article"
					message={'Share event: ' + data.title + '\n' + data.link}
					url={data.link}
				/>
			</View>
		</ScrollView>
	)
}

export default withNavigation(NewsDetail)
