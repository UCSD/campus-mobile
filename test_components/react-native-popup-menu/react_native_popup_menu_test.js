import React from 'react'
import { Text, View, StyleSheet } from 'react-native'
import {
	Menu,
	MenuOptions,
	MenuOption,
	MenuTrigger,
	MenuProvider
} from 'react-native-popup-menu'

export default class react_native_popup_menu_test extends React.Component {
	render() {
		return (
			<View style={css.dependency_output}>
				{NonRootExample()}
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { width: 200, height: 200, borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
	text_style: { fontSize: 20 },
})

const NonRootExample = () => (
	<View style={{ padding: 60, flex: 1 }}>
		<MenuProvider style={{ flexDirection: 'column' }}>
			<Text>Hello world!</Text>
			<Menu onSelect={value => alert(`Selected number: ${value}`)}>
				<MenuTrigger text='Select option' />
				<MenuOptions>
					<MenuOption value={1} text='One' />
					<MenuOption value={2}>
						<Text style={{ color: 'red' }}>Two</Text>
					</MenuOption>
					<MenuOption value={3} disabled={true} text='Three' />
				</MenuOptions>
			</Menu>
		</MenuProvider>
	</View>
)