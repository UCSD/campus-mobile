import React from 'react'
import {
	View,
	Text,
	Image,
	ActivityIndicator,
	TouchableHighlight,
	StyleSheet
} from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';
import Menu, {
	MenuContext,
	MenuOptions,
	MenuOption,
	MenuTrigger
} from 'react-native-popup-menu';
import { connect } from 'react-redux';
import { hideCard } from '../../actions/cards';

var css = require('../../styles/css');

class CardHeader extends React.Component {

	hideCard() {
		const { id, dispatch } = this.props;
		dispatch(hideCard(id));
	}

	render() {
		return (
			<View style={styles.container}>
				<Text style={styles.title}>{this.props.title}</Text>
				<Menu style={styles.menu}
						onSelect={value => this.onMenuSelect(value)}>
					<MenuTrigger style={styles.menu_trigger}>
						<Icon name="ellipsis-v" size={20} />
					</MenuTrigger>
					<MenuOptions>
						<MenuOption onSelect={() => this.props.cardRefresh()}>
							<Text>Refresh</Text>
						</MenuOption>
						<MenuOption onSelect={() => this.hideCard()}>
							<Text>Hide Card</Text>
						</MenuOption>
					</MenuOptions>
				</Menu>
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
		padding: 15
	}
})

export default connect()(CardHeader);
