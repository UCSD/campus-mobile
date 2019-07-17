import React from 'react'
import { View, StyleSheet } from 'react-native'
import Svg,{
	Circle,
	Rect
} from 'react-native-svg'

export default class react_native_svg_test extends React.Component {
	render() {
		return (
			<View style={css.dependency_output}>
				<View
					style={[StyleSheet.absoluteFill, { alignItems: 'center', justifyContent: 'center' }]}
				>
					<Svg height="50%" width="50%" viewBox="0 0 100 100">
						<Circle
							cx="50"
							cy="50"
							r="45"
							stroke="blue"
							strokeWidth="2.5"
							fill="green"
						/>
						<Rect
							x="15"
							y="15"
							width="70"
							height="70"
							stroke="red"
							strokeWidth="2"
							fill="yellow"
						/>
					</Svg>
				</View>
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, height: 200, width: 200, backgroundColor: '#FCFCFC', margin: 10 },
})
