import React from 'react';
import { View } from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';
import * as Animatable from 'react-native-animatable';

const BlueDot = ({ style }) => (
	<View
		style={style}
	>
		<View
			style={{ height: 40 }}
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
					size={40}
				/>
			</Animatable.View>
			<Icon
				style={{ top: 11, left: 9, position: 'absolute', backgroundColor : 'transparent' }}
				color="#FFF"
				name="circle"
				size={18}
			/>
			<Icon
				style={{ top: 13, left: 11, position: 'absolute', backgroundColor : 'transparent' }}
				color="#03A9F4"
				name="circle"
				size={14}
			/>
		</View>
	</View>
);

export default BlueDot;
