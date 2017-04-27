import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

import SafeImage from '../common/SafeImage';

const CardHeader = ({ title, menu, image }) => (
	<View style={styles.header_container}>
		{ image ?
			(
				<SafeImage
					source={{ uri: image }}
					style={styles.header_image}
				/>
			) : (
				<Text style={styles.header_text}>{title}</Text>
			)
		}
		{menu}
	</View>
);

const styles = StyleSheet.create({
	header_container: { flexDirection: 'row', borderBottomWidth: 1, borderBottomColor: '#DDD', alignSelf: 'stretch' },
	header_text: { fontSize: 26, color: '#747678', paddingLeft: 10, paddingVertical: 6 },
	header_image: { flex: 1, height: 50 }
});

export default CardHeader;
