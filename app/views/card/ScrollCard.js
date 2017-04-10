import React from 'react';
import { View, Text, StyleSheet, ListView } from 'react-native';
import Menu, { MenuOptions, MenuOption, MenuTrigger } from 'react-native-popup-menu';
import FAIcon from 'react-native-vector-icons/FontAwesome';
import IonIcon from 'react-native-vector-icons/Ionicons';
import { connect } from 'react-redux';
import { hideCard } from '../../actions/cards';
import CardHeader from './CardHeader';
import { getMaxCardWidth } from '../../util/general';

const css = require('../../styles/css');

const scrollDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

class ScrollCard extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			numDots: 0,
			dotIndex: 0
		};
	}

	setNativeProps(props) {
		this._card.setNativeProps(props);
	}

	refresh(refreshType) {
		return;
	}

	countDots = (width, height) => {
		const numDots = Math.floor(width / getMaxCardWidth());
		this.setState({ numDots });
	}

	handleScroll = (event) => {
		const dotIndex = Math.floor(event.nativeEvent.contentOffset.x / getMaxCardWidth());
		this.setState({ dotIndex });
	}

	_renderMenu = () => {
		// we can hide the menu if we don't want it, like for non-hideable cards
		if (this.props.hideMenu) return;

		return (
			<Menu style={css.card_menu} onSelect={value => this.menuOptionSelected(value)}>
				<MenuTrigger>
					<IonIcon size={28} style={css.card_menu_trigger} name='md-more' />
				</MenuTrigger>
				<MenuOptions>
					<MenuOption onSelect={() => { this.props.dispatch(hideCard(this.props.id)); }}>
						<Text style={css.card_hide_option}>Hide Card</Text>
					</MenuOption>
					{
						this.props.extraActions.map((action) => (
							<MenuOption
								onSelect={() => action.action(this.state.dotIndex)}
								key={action.name}
							>
								<Text style={css.card_hide_option}>{action.name}</Text>
							</MenuOption>
						))
					}
				</MenuOptions>
			</Menu>
		);
	}
	render() {
		let list;
		if (this.props.scrollData !== {}) {
			list = (
				<ListView
					style={{ flexDirection: 'row' }}
					onContentSizeChange={this.countDots}
					pagingEnabled
					horizontal
					showsHorizontalScrollIndicator={false}
					onScroll={this.handleScroll}
					scrollEventThrottle={69}
					dataSource={scrollDataSource.cloneWithRows(this.props.scrollData)}
					enableEmptySections={true}
					renderRow={this.props.renderRow}
				/>
			);
		}

		return (
			<View>
				<View style={[styles.card_main, this.state.numDots <= 1 ? styles.card_main_marginBottom : null ]} ref={(i) => { this._card = i; }}>
					<CardHeader id={this.props.id} title={this.props.title} menu={this._renderMenu()} />
					{list}
					{this.props.actionButton}
				</View>

				{ this.state.numDots > 1 ? (
					<PageIndicator
						numDots={this.state.numDots}
						dotIndex={this.state.dotIndex}
					/>
				) : null }
			</View>
		);
	}
}

const PageIndicator = ({ numDots, dotIndex }) => {
	const dots = [];
	for (let i = 0; i < numDots; ++i) {
		const dotName = (dotIndex === i) ? ('circle') : ('circle-thin');
		const dot = (
			<FAIcon
				color='#A3A3A3'
				style={{ padding: 6, paddingTop: 3 }}
				name={dotName}
				size={10}
				key={'dot' + i}
			/>
		);
		dots.push(dot);
	}

	return (
		<View
			style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'center' }}
		>
			{dots}
		</View>
	);
};

export default connect()(ScrollCard);

const styles = StyleSheet.create({
	card_main: { borderWidth: 1, borderBottomWidth: 0, borderRadius: 2, borderColor: '#DDD', backgroundColor: '#F9F9F9', margin: 6, marginBottom: 0, alignItems: 'center', justifyContent: 'center', overflow: 'hidden' },
	card_main_marginBottom: { marginBottom: 6 },
});
