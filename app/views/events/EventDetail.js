import React from 'react';
import {
	View,
	Text,
	ScrollView,
	Linking,
	StyleSheet
} from 'react-native';
import moment from 'moment';

import ShareContent from '../common/ShareContent';
import Touchable from '../common/Touchable';
import SafeImage from '../common/SafeImage';
import logger from '../../util/logger';
import general from '../../util/general';
import css from '../../styles/css';
import {
	COLOR_PRIMARY,
	COLOR_WHITE,
	COLOR_DGREY,
	COLOR_BLACK,
	COLOR_LGREY,
} from '../../styles/ColorConstants';
import {
	WINDOW_WIDTH,
} from '../../styles/LayoutConstants';

const EventDetail = ({ navigation }) => {
	const { params } = navigation.state;
	const { data } = params;

	logger.ga('View Loaded: Event Detail: ' + data.title);

	return (
		<ScrollView style={css.main_full}>

			{data.imagehq ? (
				<SafeImage
					source={{ uri: data.imagehq }}
					style={styles.image}
					resizeMode={'contain'}
				/>
			) : null }

			<View style={styles.detailContainer}>
				<Text style={styles.nameText}>
					{data.title}
				</Text>
				<Text style={styles.locationText}>
					{data.location}
				</Text>
				<Text style={styles.dateText}>
					{moment(data.eventdate).format('MMM Do') + ', ' + general.militaryToAMPM(data.starttime) + ' - ' + general.militaryToAMPM(data.endtime)}
				</Text>
				<Text style={styles.descText}>
					{data.description}
				</Text>

				{data.contact_info ? (
					<Touchable
						onPress={() => Linking.openURL('mailto:' + data.contact_info + '?')}
						style={styles.touchable}
					>
						<Text style={styles.eventdetail_readmore_text}>
							Email: {data.contact_info}
						</Text>
					</Touchable>
				) : null }
				<ShareContent
					style={styles.shareButton}
					title={'Share event'}
					message={'Share event: ' + data.title + '\n' + data.url}
					url={data.url}
				/>
			</View>
		</ScrollView>
	);
};

const styles = StyleSheet.create({
	image: { width: WINDOW_WIDTH, height: 200 },
	detailContainer: { width: WINDOW_WIDTH, paddingHorizontal: 18, paddingVertical: 14 },
	nameText: { fontWeight: '400', fontSize: 22, color: COLOR_PRIMARY },
	locationText: { fontSize: 16, color: COLOR_DGREY },
	dateText: { fontSize: 11, color: COLOR_DGREY, paddingTop: 14 },
	descText: { lineHeight: 18, color: COLOR_BLACK, fontSize: 14, paddingTop: 14 },
	touchable: { justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR_PRIMARY, borderRadius: 3, marginTop: 20, padding: 10 },
	eventdetail_readmore_text: { fontSize: 16, color: COLOR_WHITE },
	shareButton: { justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR_LGREY, borderRadius: 3, marginTop: 20, padding: 10 },
});

export default EventDetail;
