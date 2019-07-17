import React from 'react'
import { View, StyleSheet } from 'react-native'
import { AnimatedCircularProgress } from 'react-native-circular-progress'


export default class animated_circular_progress_test extends React.Component {
	render() {
		return (
			<View style={css.dependency_output}>
				<AnimatedCircularProgress
					size={120}
					width={15}
					fill={100}
					tintColor="#00e0ff"
					onAnimationComplete={() => console.log('onAnimationComplete')}
					backgroundColor="#3d5875" 
				/>
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
