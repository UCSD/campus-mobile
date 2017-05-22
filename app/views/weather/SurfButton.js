import React from 'react';
import {
	Text,
	StyleSheet,
} from 'react-native';
import { Actions } from 'react-native-router-flux';

import {
	COLOR_PRIMARY,
	COLOR_MGREY
} from '../../styles/ColorConstants';
import {
	MAX_CARD_WIDTH
} from '../../styles/LayoutConstants';
import Touchable from '../common/Touchable';

const SurfButton = () => (
	<Touchable
		style={styles.touchable}
		onPress={() => Actions.SurfReport()}
	>
		<Text style={styles.text}>Surf Report &raquo;</Text>
	</Touchable>
);

const styles = StyleSheet.create({
	touchable: { borderTopWidth: 1, borderTopColor: COLOR_MGREY, width: MAX_CARD_WIDTH },
	text: { fontSize: 20, fontWeight: '300', color: COLOR_PRIMARY, paddingHorizontal: 14, paddingVertical: 10,  },
});

export default SurfButton;
