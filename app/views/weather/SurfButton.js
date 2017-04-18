import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	StyleSheet,
} from 'react-native';
import { Actions } from 'react-native-router-flux';

import {
	getMaxCardWidth,
	getCampusPrimary
} from '../../util/general';

const SurfButton = () => (
	<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => Actions.SurfReport()}>
		<View style={styles.wc_border}>
			<Text style={styles.wc_surfreport_more}>Surf Report &raquo;</Text>
		</View>
	</TouchableHighlight>
);

const styles = StyleSheet.create({
	wc_border: { borderTopWidth: 1, borderTopColor: '#CCC', width: getMaxCardWidth() },
	wc_surfreport_more: { fontSize: 20, fontWeight: '300', color: getCampusPrimary(), paddingHorizontal: 14, paddingVertical: 10 },
});

export default SurfButton;
