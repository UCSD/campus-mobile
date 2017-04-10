import React from 'react';
import { View } from 'react-native';
import * as Animatable from 'react-native-animatable';

const BlueDot = ({ dotSize, dotStyle }) => {
	const innerWhiteDotSize = dotSize * 0.6,
		innerBlueDotSize = dotSize * 0.5;

	return (
		<View style={dotStyle}>
			<Animatable.View
				style={{ width: dotSize, height: dotSize, borderRadius: dotSize / 2, borderColor: '#B3E5FC', borderWidth: dotSize / 2, zIndex: 2 }}
				ref={c => { this._view = c; }}
				animation='zoomIn'
				easing='ease'
				iterationCount='infinite'
			/>
			<View style={{ position: 'absolute', top: ((dotSize - innerWhiteDotSize) / 2), left: ((dotSize - innerWhiteDotSize) / 2), width: innerWhiteDotSize, height: innerWhiteDotSize, borderRadius: innerWhiteDotSize / 2, borderColor: 'white', borderWidth: innerWhiteDotSize / 2, zIndex: 3 }} />
			<View style={{ position: 'absolute', top: ((dotSize - innerBlueDotSize) / 2), left: ((dotSize - innerBlueDotSize) / 2), width: innerBlueDotSize, height: innerBlueDotSize, borderRadius: innerBlueDotSize / 2, borderColor: '#03A9F4', borderWidth: innerBlueDotSize / 2, zIndex: 4 }} />
		</View>
	);
};

export default BlueDot;
