import React from 'react';
import { Text, StyleSheet } from 'react-native';
import { COLOR_DGREY, COLOR_VDGREY, COLOR_MGREY} from '../../styles/ColorConstants';

const ScheduleText = props => (
	<Text
		numberOfLines={1}
		ellipsizeMode="tail"
		allowFontScaling={false}
		style={[
			{
				lineHeight: (() => Math.round(StyleSheet.flatten(props.style).fontSize * (1.2)))(),
				color: COLOR_VDGREY
			},
			props.style]}
	>
		{props.children}
	</Text>
);

export default ScheduleText;
