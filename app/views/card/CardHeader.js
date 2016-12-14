import React from 'react';
import {
	View,
	Text,
	StyleSheet,
} from 'react-native';

import Menu, {
	MenuContext,
	MenuOptions,
	MenuOption,
	MenuTrigger,
} from 'react-native-popup-menu';

import Icon from 'react-native-vector-icons/FontAwesome';
import { connect } from 'react-redux';
import { hideCard } from '../../actions/cards';

class CardHeader extends React.Component {
	_renderMenu = () => {
		// we can hide the menu if we don't want it, like for non-hideable cards
		if (this.props.hideMenu) return;

		return (
			<Menu style={styles.menu} onSelect={value => this.menuOptionSelected(value)}>
				<MenuTrigger style={styles.menu_trigger}>
					<Icon size={20} name="ellipsis-v" />
				</MenuTrigger>
				<MenuOptions>
					<MenuOption onSelect={() => { this.props.dispatch(hideCard(this.props.id)); }}>
						<Text>Hide Card</Text>
					</MenuOption>
					<MenuOption value={2}>
						<Text style={{ color: 'red' }}>Two</Text>
					</MenuOption>
				</MenuOptions>
			</Menu>
		);
	}
	render() {
		return (
			<View style={styles.container}>
				<Text style={styles.title}>{this.props.title}</Text>
				{this._renderMenu()}
			</View>
		);
	}
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		flexDirection: 'row',
		alignItems: 'center',
		borderBottomWidth: 1,
		borderBottomColor: '#DDD',
		alignSelf: 'stretch',
	},
	title: {
		fontSize: 26,
		margin: 8,
		color: '#747678'
	},
	menu: {
		flex: 1,
		flexDirection: 'row',
		justifyContent: 'flex-end',
		alignItems: 'center',
		alignSelf: 'stretch',
	},
	menu_trigger: {
		padding: 15,
	}
});

export default connect()(CardHeader);
