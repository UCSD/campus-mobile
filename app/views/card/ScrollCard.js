import React from 'react';
import { View, StyleSheet, ListView } from 'react-native';
import FAIcon from 'react-native-vector-icons/FontAwesome';
import { connect } from 'react-redux';
import ElevatedView from 'react-native-elevated-view';

import { hideCard } from '../../actions/cards'; // TODO: Use saga
import CardHeader from './CardHeader';
import CardMenu from './CardMenu';
import { getMaxCardWidth } from '../../util/general';
import {
	COLOR_DGREY,
	COLOR_LGREY
} from '../../styles/ColorConstants';

const scrollDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

class ScrollCard extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			numDots: 0,
			dotIndex: 0
		};
	}

	componentDidMount() {
		this._listview.scrollTo({ x: this.props.lastScroll, animated: false });
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
		if (this.props.updateScroll) {
			this.props.updateScroll(event.nativeEvent.contentOffset.x);
		}
		const dotIndex = Math.floor(event.nativeEvent.contentOffset.x / (getMaxCardWidth() - 12)); // minus padding
		this.setState({ dotIndex });
	}

	render() {
		let list;
		if (this.props.scrollData !== {}) {
			list = (
				<ListView
					ref={c => { this._listview = c; }}
					style={styles.listStyle}
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
				<ElevatedView
					elevation={3}
					style={[styles.card_main, this.state.numDots <= 1 ? styles.card_main_marginBottom : null]}
					ref={(i) => { this._card = i; }}
				>
					<CardHeader
						id={this.props.id}
						title={this.props.title}
						menu={
							<CardMenu
								hideCard={this.props.hide}
								cardRefresh={this.props.cardRefresh}
								extraActions={this.props.extraActions}
								id={this.props.id}
							/>
						}
					/>
					{list}
					{this.props.actionButton}
				</ElevatedView>

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
				style={styles.dotStyle}
				name={dotName}
				size={10}
				key={'dot' + i}
			/>
		);
		dots.push(dot);
	}

	return (
		<View
			style={styles.dotsContainer}
		>
			{dots}
		</View>
	);
};

const mapDispatchToProps = (dispatch) => (
	{
		hide: (id) => {
			dispatch(hideCard(id));
		}
	}
);

export default connect(null, mapDispatchToProps)(ScrollCard);

const styles = StyleSheet.create({
	card_main: { backgroundColor: COLOR_LGREY, margin: 6, marginBottom: 0, alignItems: 'center', justifyContent: 'center', },
	card_main_marginBottom: { marginBottom: 6 },
	dotStyle: { padding: 6, paddingTop: 3, backgroundColor:'transparent', color: COLOR_DGREY },
	dotsContainer: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center' },
	listStyle: { flexDirection: 'row' },
});
