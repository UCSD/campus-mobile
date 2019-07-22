import React from 'react'
import { View, StyleSheet, Text, Button } from 'react-native'
import SystemSetting from 'react-native-system-setting'

export default class react_native_system_setting_test extends React.Component {
	state = {
		volumeText: null,
		wifi: null
	}

	componentDidMount() {
		SystemSetting.getVolume().then((volume) => {
			this.setState({ volumeText: 'Current volume is ' + volume })
		})
		SystemSetting.isWifiEnabled().then((enable) => {
			const state = enable ? 'On' : 'Off'
			this.setState({ wifi: 'Current wifi is ' + state })
		})
	}

	render() {
		return (
			<View style={css.dependency_output}>
				<Text>
					{this.state.volumeText ? this.state.volumeText : 'volume is null' }
				</Text>
				<Text>
					{this.state.wifi ? this.state.wifi : 'wifi is null'}
				</Text>
				<Button
					onPress={() => SystemSetting.openAppSystemSettings()}
					title="Open System Setting"
				/>
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
