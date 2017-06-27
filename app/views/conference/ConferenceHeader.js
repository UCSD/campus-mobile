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

const ConferenceHeader = ({ timestamp }) => (
	<View
		style={styles.header}
	>
		<Text style={styles.headerText}>
			{moment(Number(timestamp)).format('h:mm')}
		</Text>
	</View>
);

const styles = StyleSheet.create({
	header: { justifyContent: 'flex-start', alignItems: 'center', width: 45, backgroundColor: COLOR_LGREY, borderBottomWidth: 1, borderColor: COLOR_LGREY },
	headerText: { textAlign: 'right', alignSelf: 'stretch', color: COLOR_BLACK, fontSize: 12, marginTop: 7 },
});

export default ConferenceHeader;
