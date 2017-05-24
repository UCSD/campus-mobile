import React from 'react';
import {
	StyleSheet,
	View,
	Text,
} from 'react-native';
import Icon from 'react-native-vector-icons/Ionicons';

import Card from '../card/Card';
import SafeImage from './SafeImage';
import Touchable from '../common/Touchable';
import {
	MAX_CARD_WIDTH
} from '../../styles/LayoutConstants';
import {
	COLOR_PRIMARY,
	COLOR_DGREY
} from '../../styles/ColorConstants';

const BannerCard = ({ image, onPress, onClose }) => (
	<Card>
		<Touchable
			onPress={() => onClose()}
			style={styles.closeContainer}
		>
			<Text style={styles.closeText}>Close</Text>
			<Icon
				size={13}
				name={'md-close-circle'}
				style={styles.closeIcon}
			/>
		</Touchable>
		<Touchable
			onPress={() => onPress()}
		>
			<SafeImage
				source={{ uri: image }}
				style={styles.image}
			/>
			<View style={styles.more}>
				<Text style={styles.moreText}>See Full Schedule</Text>
			</View>
		</Touchable>
	</Card>
);

const styles = StyleSheet.create({
	image: { height: ((MAX_CARD_WIDTH / 1242) * 440), width: MAX_CARD_WIDTH, marginTop: 22 },
	closeContainer: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', zIndex: 10, position: 'absolute', top: 3, right: 3 },
	closeText: { color: COLOR_DGREY, fontSize: 10, marginBottom: 2 },
	closeIcon: { color: COLOR_DGREY, marginLeft: 2 },
	more: { alignItems: 'center', justifyContent: 'center', paddingHorizontal: 4, paddingTop: 6, paddingBottom: 4 },
	moreText: { fontSize: 20, color: COLOR_PRIMARY, fontWeight: '300' },

});

export default BannerCard;
