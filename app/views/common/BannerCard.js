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
	COLOR_DGREY,
	COLOR_MGREY,
} from '../../styles/ColorConstants';

const BannerCard = ({ title, image, onPress, onClose }) => (
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
			{image ? (
				<SafeImage
					source={{ uri: image }}
					style={styles.image}
				/>
			) : (
				<Text style={styles.cardTitle}>{title}</Text>
			)}
			<View style={styles.more}>
				<Text style={styles.more_label}>See Full Schedule</Text>
			</View>
		</Touchable>
	</Card>
);

const styles = StyleSheet.create({
	image: { height: ((MAX_CARD_WIDTH / 1242) * 440), width: MAX_CARD_WIDTH },
	cardTitle: { color: COLOR_PRIMARY, width: MAX_CARD_WIDTH, textAlign: 'center', fontSize: 50, fontWeight: '600', paddingVertical: 30 },
	closeContainer: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', zIndex: 10, position: 'absolute', top: 3, right: 3 },
	closeText: { color: COLOR_MGREY, fontSize: 10, marginBottom: 2, backgroundColor: 'transparent' },
	closeIcon: { color: COLOR_MGREY, marginLeft: 2, backgroundColor: 'transparent' },
	more: { alignSelf: 'stretch', justifyContent: 'center', padding: 6, borderTopWidth: 1, borderTopColor: COLOR_MGREY },
	more_label: { fontSize: 20, color: COLOR_PRIMARY, textAlign: 'center', fontWeight: '300' },

});

export default BannerCard;
