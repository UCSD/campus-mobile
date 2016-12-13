import React from 'react';
import {
	View,
	Text,
} from 'react-native';

import Menu, {
	MenuContext,
	MenuOptions,
	MenuOption,
	MenuTrigger,
} from 'react-native-popup-menu';

import Icon from 'react-native-vector-icons/FontAwesome';

const css = require('../../styles/css');

export default class CardHeader extends React.Component {
	render() {
		const menu = (
			<MenuContext style={{ flexDirection: 'column', paddingRight: 10 }}>
				<Menu onSelect={value => alert(`Selected number: ${value}`)}>
					<MenuTrigger>
						<View style={{ alignSelf: 'flex-end', paddingTop: 5 }}>
							<Icon size={20} name="ellipsis-v" />
						</View>
					</MenuTrigger>
					<MenuOptions>
						<MenuOption value={1} text="One" />
						<MenuOption value={2}>
							<Text style={{ color: 'red' }}>Two</Text>
						</MenuOption>
					</MenuOptions>
				</Menu>
			</MenuContext>
		);
		return (
			<View style={css.card_title_container}>
				<View>
					<Text style={css.card_title}>{this.props.title}</Text>
				</View>
				<View style={{ flex: 1, justifyContent: 'center' }}>
					{menu}
				</View>
			</View>
		);
	}
}
