import React from 'react';
import { View } from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';
import * as Animatable from 'react-native-animatable';

const BlueDot = () => (
	<View
		style={{ height: 80 }}
	>
		<Animatable.View
			ref={c => { this._view = c; }}
			animation="zoomIn"
			easing="ease"
			iterationCount="infinite"
		>
			<Icon
				color="#B3E5FC"
				name="circle"
				size={80}
			/>
		</Animatable.View>
		<Icon
			style={{ top: 28, left: 23, position: 'absolute', backgroundColor : 'transparent' }}
			color="#FFF"
			name="circle"
			size={24}
		/>
		<Icon
			style={{ top: 30, left: 25, position: 'absolute', backgroundColor : 'transparent' }}
			color="#03A9F4"
			name="circle"
			size={20}
		/>
	</View>
);

export default BlueDot;
