import React from 'react'
import { Text } from 'react-native'
import { Menu, MenuOptions, MenuOption, MenuTrigger } from 'react-native-popup-menu'
import Icon from 'react-native-vector-icons/Ionicons'

import css from '../../styles/css'

const CardMenu = ({
	hideMenu,
	cardRefresh,
	extraActions,
	hideCard,
	id
}) => {
	let extraOptions
	if (extraActions) {
		extraOptions = extraActions.map(action => (
			<MenuOption
				onSelect={() => action.action()}
				key={action.name}
			>
				<Text style={css.cm_option}>{action.name}</Text>
			</MenuOption>
		))
	}

	if (!hideMenu) {
		return (
			<Menu style={css.cm_menu} onSelect={value => this.menuOptionSelected(value)}>
				<MenuTrigger>
					<Icon size={28} style={css.cm_trigger} name="md-more" />
				</MenuTrigger>
				<MenuOptions>
					{
						(cardRefresh) ? (
							<MenuOption onSelect={() => { cardRefresh() }}>
								<Text style={css.cm_option}>Refresh</Text>
							</MenuOption>
						) : (null)
					}
					{extraOptions}
					<MenuOption onSelect={() => { hideCard(id) }}>
						<Text style={css.cm_option}>Hide Card</Text>
					</MenuOption>
				</MenuOptions>
			</Menu>
		)
	} else {
		return null
	}
}

export default CardMenu
