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
import SafeImage from '../common/SafeImage';
import logger from '../../util/logger';
import Touchable from '../common/Touchable';
import css from '../../styles/css';
import {
	COLOR_PRIMARY,
	COLOR_WHITE,
	COLOR_DGREY,
	COLOR_BLACK,
	COLOR_MGREY,
	COLOR_LGREY,
} from '../../styles/ColorConstants';
import {
	WINDOW_WIDTH,
} from '../../styles/LayoutConstants';

const NewsDetail = ({ data }) => {
	logger.ga('View Loaded: News Detail: ' + data.title);

	return (
		<ScrollView style={css.main_full}>
			{data.image_lg ? (
				<SafeImage
					source={{ uri: data.image_lg }}
					style={styles.image}
					resizeMode={'contain'}
				/>
			) : null }

			<View style={styles.detailContainer}>
				<Text style={styles.titleText}>{data.title}</Text>
				<Text style={styles.dateText}>
					{moment(styles.date).format('MMM Do, YYYY')}
				</Text>
				<Text style={styles.descText}>{data.description}</Text>
				{data.link ? (
					<Touchable
						onPress={() => Linking.openURL(data.link)}
						style={styles.touchable}
					>
						<Text style={styles.readMoreText}>Read the full article</Text>
					</Touchable>
				) : null }
				<ShareContent
					style={styles.shareButton}
					title={'Share news'}
					message={'Share event: ' + data.title + '\n' + data.link}
					url={data.link}
				/>
			</View>
		</ScrollView>
	);
};

const styles = StyleSheet.create({
	image: { width: WINDOW_WIDTH, height: 200 },
	detailContainer: { width: WINDOW_WIDTH, paddingHorizontal: 18, paddingVertical: 14 },
	titleText: { fontWeight: '400', fontSize: 22, color: COLOR_PRIMARY },
	dateText: { fontSize: 11, color: COLOR_DGREY, paddingTop: 14 },
	descText: { lineHeight: 18, color: COLOR_BLACK, fontSize: 14, paddingTop: 14 },
	touchable: { justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR_PRIMARY, borderRadius: 3, marginTop: 20, padding: 10 },
	readMoreText: { fontSize: 16, color: COLOR_WHITE },
	shareButton: { justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR_LGREY, borderRadius: 3, marginTop: 20, padding: 10 },
});

export default NewsDetail;
