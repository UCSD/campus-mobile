import React from 'react';
import {
	View,
	Text,
	ListView,
	StyleSheet,
	TouchableHighlight,
	List,
	FlatList
} from 'react-native';
import { connect } from 'react-redux';
import ElevatedView from 'react-native-elevated-view';

import {
	COLOR_LGREY
} from '../../styles/ColorConstants';
import CardHeader from './CardHeader';
import CardMenu from './CardMenu';


class Card extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			data: {}
		};
	}

	render() {
		let list;
		if (this.props.data !== {}) {
			list = (
				// <ListView
				// 	ref={c => { this._listview = c; }}
				// 	style={styles.listStyle}
				// 	onContentSizeChange={this.countDots}
				// 	pagingEnabled
				// 	horizontal
				// 	showsHorizontalScrollIndicator={false}
				// 	onScroll={this.handleScroll}
				// 	scrollEventThrottle={69}
				// 	dataSource={scrollDataSource.cloneWithRows(this.props.scrollData)}
				// 	enableEmptySections={true}
				// 	renderRow={this.props.renderRow}
				// />
			<View style={{ flex: 1, alignItems: "center", justifyContent: "center" }}>
				<Text>Coming soon...</Text>
			</View>
			);
		}

		return (
			<View>
				<ElevatedView
					style={styles.mainContainer}
					ref={(i) => { this._card = i; }}
					elevation={3}
				>
					<CardHeader
						id={this.props.id}
						title={this.props.title}
						menu={
							<CardMenu
								hideMenu={this.props.hideMenu}
								hideCard={this.props.hide}
								cardRefresh={this.props.cardRefresh}
								id={this.props.id}
							/>
						}
						image={this.props.header}
					/>
					{list}
				</ElevatedView>
			</View>
		);
	}
}

const mapDispatchToProps = (dispatch) => (
	{
		hide: (id) => {
			dispatch({ type: 'UPDATE_CARD_STATE', id, state: false });
		}
	}
);

const styles = StyleSheet.create({
	mainContainer: { backgroundColor: COLOR_LGREY, margin: 6, alignItems: 'flex-start', justifyContent: 'center' },
});

export default connect(null, mapDispatchToProps)(Card);
