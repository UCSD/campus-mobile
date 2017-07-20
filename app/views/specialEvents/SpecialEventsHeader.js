import React from 'react';
import {
	View,
	Text,
	StyleSheet,
} from 'react-native';
import moment from 'moment';

import {
	COLOR_LGREY,
	COLOR_BLACK,
} from '../../styles/ColorConstants';

const SpecialEventsHeader = ({ timestamp, rows }) => (
	<View
		style={styles.header}
	>
		<Text style={styles.headerText}>
			{rows ? (
				moment(Number(timestamp)).format('MMM D[\n]h:mm A')
			) : (
				moment(Number(timestamp)).format('h:mm A')
			)}
		</Text>
	</View>
);

const styles = StyleSheet.create({
	header: { justifyContent: 'flex-start', alignItems: 'center', width: 75, backgroundColor: COLOR_LGREY },
	headerText: { textAlign: 'center', alignSelf: 'stretch', color: COLOR_BLACK, fontSize: 12, marginTop: 7 },
});

export default SpecialEventsHeader;
