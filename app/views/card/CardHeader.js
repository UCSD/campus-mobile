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
		<View style={styles.filler} />
		{menu}
	</View>
);

const styles = StyleSheet.create({
	header_container: { flexDirection: 'row', borderBottomWidth: 1, borderBottomColor: '#DDD' },
	header_text: { flexGrow: 1, fontSize: 26, color: '#747678', paddingLeft: 10, paddingVertical: 6 },
	header_image: { height: 40, width: 132, margin: 3 },
	filler: { flexGrow: 1 },
});

export default CardHeader;
