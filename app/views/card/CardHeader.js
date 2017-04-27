import React from 'react';
<<<<<<< HEAD
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
=======
import { View, Text } from 'react-native';

const css = require('../../styles/css');

const CardHeader = ({ title, menu }) => (
	<View style={css.card_title_main}>
		<Text style={css.card_title_text}>{title}</Text>
>>>>>>> v5.1-hotfix
		{menu}
	</View>
);

<<<<<<< HEAD
const styles = StyleSheet.create({
	header_container: { flexDirection: 'row', borderBottomWidth: 1, borderBottomColor: '#DDD', alignSelf: 'stretch' },
	header_text: { fontSize: 26, color: '#747678', paddingLeft: 10, paddingVertical: 6 },
	header_image: { flex: 1, height: 50 }
});

=======
>>>>>>> v5.1-hotfix
export default CardHeader;
