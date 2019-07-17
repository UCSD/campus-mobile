import React from 'react'
import { View } from 'react-native'
import { HeaderButtons, Item } from 'react-navigation-header-buttons'

export default class react_navigation_header_buttons_test extends React.Component {
	static navigationOptions = {
		title: 'Custom',
		headerRight: (
			<HeaderButtons>
				<Item
					title="shifted"
					buttonWrapperStyle={{ marginTop: 10 }}
					onPress={() => alert('misaligned')}
				/>
				<Item
					title="add"
					ButtonElement={<View style={{ height: 25, width: 25, backgroundColor: 'green' }} />}
					buttonWrapperStyle={{ marginTop: -10 }}
					onPress={() => alert('green square')}
				/>
			</HeaderButtons>
		),
	}

	render() {
		return <View />
	}
}