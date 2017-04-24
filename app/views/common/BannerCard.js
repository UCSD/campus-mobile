import React from 'react';
import { TouchableOpacity, StyleSheet } from 'react-native';

import Card from '../card/Card';
import SafeImage from './SafeImage';
import { getMaxCardWidth } from '../../util/general';

const BannerCard = ({ image, onPress }) => (
	<Card>
		<TouchableOpacity
			onPress={() => onPress()}
		>
			<SafeImage
				source={{ uri: image }}
				style={styles.image}
			/>
		</TouchableOpacity>
	</Card>
);

const styles = StyleSheet.create({
	image: { height: 200, width: getMaxCardWidth() }
});

export default BannerCard;
