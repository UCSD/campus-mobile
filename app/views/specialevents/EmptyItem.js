import React from 'react';
import {
	View,
	StyleSheet,
} from 'react-native';

import {
	COLOR_LGREY,
} from '../../styles/ColorConstants';

const EmptyItem = () => (
	<View style={styles.emptyRow} />
);

const styles = StyleSheet.create({
	emptyRow: { width: 45, flexDirection: 'row',  backgroundColor: COLOR_LGREY, borderBottomWidth: 1, borderColor: COLOR_LGREY },
});

export default EmptyItem;
