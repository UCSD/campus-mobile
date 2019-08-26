import React from 'react'
import { View, Text } from 'react-native'
import css from '../../../../styles/css'

const CourseTitle = ({
	unit = '-1',
	code = 'Unknown',
	title = 'Unknown',
	term = '',
	containerStyle,
	fontColor
}) => (
	<View style={[css.webreg_common_title_container, containerStyle]} >
		<View style={css.webreg_common_unit_container}>
			<View style={css.webreg_common_unit_bg}>
				<Text style={css.webreg_common_unit_text} allowFontScaling={false} >
					{unit}
				</Text>
			</View>
		</View>
		<View style={css.webreg_common_name_container}>
			<Text style={[css.webreg_common_code, fontColor]}>{code}</Text>
			<Text style={[css.webreg_common_title, fontColor]}>{title}</Text>
		</View>
		<View style={css.webreg_common_term_container}>
			<Text style={css.webreg_common_term}>{term}</Text>
		</View>
	</View>
)

export default CourseTitle