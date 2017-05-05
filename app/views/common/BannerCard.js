import React from 'react';
import {
	TouchableOpacity,
	StyleSheet,
	View,
	Text,
} from 'react-native';

import Card from '../card/Card';
import SafeImage from './SafeImage';
import { getMaxCardWidth, getCampusPrimary } from '../../util/general';
import Icon from 'react-native-vector-icons/Ionicons';

const BannerCard = ({ image, onPress }) => (
	<Card>
		<View style={styles.closeContainer}>
			<TouchableOpacity
				activeOpacity={0.6}
				style={{flexDirection: 'row'}}
				onPress={() => onPress()}
			>	
				<Text style={styles.closeText}>Close</Text>
				<Icon size={13} color={'grey'} name={'md-close-circle'} style={styles.closeIcon} />
			</TouchableOpacity>
		</View>


		<TouchableOpacity
			activeOpacity={0.6}
			onPress={() => onPress()}
		>
			<SafeImage
				source={{ uri: image }}
				style={styles.image}
			/>
			<View style={styles.more}>
				<Text style={styles.more_label}>See Full Schedule</Text>
			</View>
		</TouchableOpacity>
	</Card>
);

const styles = StyleSheet.create({
	image: { height: ((getMaxCardWidth() / 840) * 240), width: getMaxCardWidth(), marginTop: 22 },
	closeContainer: { justifyContent: 'center', alignItems: 'center', zIndex: 10, position: 'absolute', top: 3, right: 3 },
	closeText: { color: 'grey', fontSize: 10, marginBottom: 2 },
	closeIcon: { color: 'grey', marginLeft: 2 },
	more: { alignItems: 'center', justifyContent: 'center', paddingHorizontal: 4, paddingTop: 6, paddingBottom: 4 },
	more_label: { fontSize: 20, color: getCampusPrimary(), fontWeight: '300' },

});

export default BannerCard;
