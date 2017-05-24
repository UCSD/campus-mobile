import React from 'react';
import { StyleSheet, Text } from 'react-native';
import { Menu, MenuOptions, MenuOption, MenuTrigger } from 'react-native-popup-menu';
import Icon from 'react-native-vector-icons/Ionicons';

import {
	COLOR_DGREY
} from '../../styles/ColorConstants';

const CardMenu = ({ hideMenu, cardRefresh, extraActions, hideCard, id }) => {
	let extraOptions;
	if (extraActions) {
		extraOptions = extraActions.map((action) => (
			<MenuOption
				onSelect={() => action.action()}
				key={action.name}
			>
				<Text style={styles.option}>{action.name}</Text>
			</MenuOption>
		));
	}

	return (
		hideMenu ? (null) :
		(<Menu style={styles.menu} onSelect={value => this.menuOptionSelected(value)}>
			<MenuTrigger>
				<Icon size={28} style={styles.trigger} name="md-more" />
			</MenuTrigger>
			<MenuOptions>
				<MenuOption onSelect={() => { hideCard(id); }}>
					<Text style={styles.option}>Hide Card</Text>
				</MenuOption>
				{
					(cardRefresh) ? (
						<MenuOption onSelect={() => { cardRefresh(); }}>
							<Text style={styles.option}>Refresh</Text>
						</MenuOption>
					) : (null)
				}
				{extraOptions}
			</MenuOptions>
		</Menu>)
	);
};

const styles = StyleSheet.create({
	menu: { flexDirection: 'row', justifyContent: 'flex-end', },
	option: { margin: 10, fontSize: 16 },
	trigger: { paddingTop: 9, paddingBottom: 6, paddingLeft: 12, paddingRight: 10, color: COLOR_DGREY, },
});

export default CardMenu;
