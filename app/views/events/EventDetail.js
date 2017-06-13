import React from 'react';
import {
	View,
	Text,
	ScrollView,
	Linking,
	TouchableHighlight,
	StyleSheet
} from 'react-native';

import moment from 'moment';

import SafeImage from '../common/SafeImage';
import logger from '../../util/logger';
import general from '../../util/general';
import {
	COLOR_PRIMARY,
	COLOR_WHITE,
	COLOR_DGREY,
	COLOR_BLACK,
	COLOR_MGREY,
} from '../../styles/ColorConstants';
import {
	WINDOW_WIDTH,
	MARGIN_TOP,
} from '../../styles/LayoutConstants';

const EventDetail = ({ data }) => {
	logger.ga('View Loaded: Event Detail: ' + data.title);

	return (
		<ScrollView style={styles.main_container}>

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
					<TouchableHighlight
						underlayColor={'rgba(200,200,200,.1)'}
						onPress={() => Linking.openURL('mailto:' + data.contact_info + '?')}
						style={styles.touchable}
					>
						<Text style={styles.eventdetail_readmore_text}>
							Email: {data.contact_info}
						</Text>
					</TouchableHighlight>
				) : null }

			</View>
		</ScrollView>
	);
};

const styles = StyleSheet.create({
	main_container: { flexGrow: 1, backgroundColor: COLOR_MGREY, marginTop: MARGIN_TOP },
	image: { width: WINDOW_WIDTH, height: 200 },
	detailContainer: { width: WINDOW_WIDTH, paddingHorizontal: 18, paddingVertical: 14 },
	nameText: { fontWeight: '400', fontSize: 22, color: COLOR_PRIMARY },
	locationText: { fontSize: 16, color: COLOR_DGREY },
	dateText: { fontSize: 11, color: COLOR_DGREY, paddingTop: 14 },
	descText: { lineHeight: 18, color: COLOR_BLACK, fontSize: 14, paddingTop: 14 },
	touchable: { justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR_PRIMARY, borderRadius: 3, marginTop: 20, padding: 10 },
	eventdetail_readmore_text: { fontSize: 16, color: COLOR_WHITE },
});

export default EventDetail;
