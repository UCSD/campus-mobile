import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

import SafeImage from '../common/SafeImage';
import {
	COLOR_MGREY,
	COLOR_DGREY
} from '../../styles/ColorConstants';

/*
	CardHeader component that will display image over text if given
 */
const CardHeader = ({ title, menu, image }) => (
	<View style={styles.headerContainer}>
		{ image ?
			(
				<SafeImage
					source={{ uri: image }}
					style={styles.titleImage}
				/>
			) : (
				<Text style={styles.titleText}>
					{title}
				</Text>
			)
		}
		<View style={styles.filler} />
		{menu}
	</View>
);

const styles = StyleSheet.create({
	headerContainer: { flexDirection: 'row', borderBottomWidth: 1, borderBottomColor: COLOR_MGREY },
	titleText: { flexGrow: 1, fontSize: 26, color: COLOR_DGREY, paddingLeft: 10, paddingVertical: 6 },
	titleImage: { height: 36, minWidth: 85, maxWidth: 150, marginTop: 6, marginLeft: 6 },
	filler: { flexGrow: 1 },
});

export default CardHeader;
