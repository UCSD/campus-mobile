import React from 'react';
import {
	View,
	ScrollView,
	StyleSheet
} from 'react-native';

import SafeImage from '../common/SafeImage';

const DiningImages = ({ images }) => (
	<View>
		{(images) ? (
			<ScrollView
				style={styles.scrollView}
				directionalLockEnabled={false}
				horizontal={true}
			>
				{images.map((object, i) => (
					<SafeImage
						key={i}
						style={styles.image}
						resizeMode={'cover'}
						source={{ uri: object }}
					/>
				))}
			</ScrollView>
		) : null }
	</View>
);

const styles = StyleSheet.create({
	scrollView: { height: 140 },
	image: { width: 140, height: 140, borderRadius: 5, marginHorizontal: 7 },
});

export default DiningImages;
