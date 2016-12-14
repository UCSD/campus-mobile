import React from 'react';
import {
	View,
	Text,
	StyleSheet
} from 'react-native';

import Menu, {
	MenuOptions,
	MenuOption,
	MenuTrigger,
} from 'react-native-popup-menu';

import Icon from 'react-native-vector-icons/FontAwesome';
import { connect } from 'react-redux';
import { hideCard } from '../../actions/cards';

import CardHeader from './CardHeader';

const css = require('../../styles/css');

class Card extends React.Component {
	setNativeProps(props) {
		this._card.setNativeProps(props);
	}

	refresh(refreshType) {
		return;
	}
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
						<Text style={{ color: 'red' }}>Feedback (TODO)</Text>
					</MenuOption>
				</MenuOptions>
			</Menu>
		);
	}
	render() {
		return (
			<View style={css.card_main} ref={(i) => { this._card = i; }}>
				<CardHeader id={this.props.id} title={this.props.title} menu={this._renderMenu()} />
				{this.props.children}
			</View>
		);
	}
}

const styles = StyleSheet.create({
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

export default connect()(Card);
