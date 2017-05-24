import React from 'react';
import { View } from 'react-native';
import * as Animatable from 'react-native-animatable';

import {
	COLOR_WHITE,
	COLOR_LBLUE,
	COLOR_MBLUE
} from '../../styles/ColorConstants';

const BlueDot = ({ dotSize, dotStyle }) => {
	const innerWhiteDotSize = dotSize * 0.6,
		innerBlueDotSize = dotSize * 0.5;

	return (
		<View style={dotStyle}>
			<Animatable.View
				style={{ width: dotSize, height: dotSize, borderRadius: dotSize / 2, borderColor: COLOR_LBLUE, borderWidth: dotSize / 2, zIndex: 2 }}
				ref={c => { this._view = c; }}
				animation="zoomIn"
				easing="ease"
				iterationCount="infinite"
			/>
			<View style={{ position: 'absolute', top: ((dotSize - innerWhiteDotSize) / 2), left: ((dotSize - innerWhiteDotSize) / 2), width: innerWhiteDotSize, height: innerWhiteDotSize, borderRadius: innerWhiteDotSize / 2, borderColor: COLOR_WHITE, borderWidth: innerWhiteDotSize / 2, zIndex: 3 }} />
			<View style={{ position: 'absolute', top: ((dotSize - innerBlueDotSize) / 2), left: ((dotSize - innerBlueDotSize) / 2), width: innerBlueDotSize, height: innerBlueDotSize, borderRadius: innerBlueDotSize / 2, borderColor: COLOR_MBLUE, borderWidth: innerBlueDotSize / 2, zIndex: 4 }} />
		</View>
	);
};

export default BlueDot;
