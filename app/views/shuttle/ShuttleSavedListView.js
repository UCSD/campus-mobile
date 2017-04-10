import React from 'react';
import {
	Text,
	StyleSheet,
	ListView,
	Dimensions,
	Animated,
	Platform,
	Easing
} from 'react-native';
import SortableList from 'react-native-sortable-list';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { connect } from 'react-redux';

import css from '../../styles/css';


const deviceWidth = Dimensions.get('window').width;

class ShuttleSavedListView extends React.Component {
	componentWillMount() {
		const savedStops = this.props.savedStops.slice();
		const { closestStop } = this.props;

		savedStops.splice(closestStop.savedIndex, 0, closestStop);
		const savedObject = {};
		for (let i = 0; i < savedStops.length; ++i) {
			savedObject[i] = savedStops[i];
		}
		this.setState({ savedObject });
	}

	shouldComponentUpdate() {
		return false; // stop list from re-rendering
	}

	render() {
		return (
			<SortableList
				style={[css.main_container, css.scroll_main, css.whitebg]}
				data={this.state.savedObject}
				renderRow={
					({ data, active, disabled }) =>
						<SavedItem
							data={data}
							active={active}
						/>
				}
				onChangeOrder={(nextOrder) => { this._order = nextOrder; }}
				onReleaseRow={(key) => this.props.orderStops(this._order)}
			/>
		);
	}
}

class SavedItem extends React.Component {

	constructor(props) {
		super(props);

		this._active = new Animated.Value(0);

		this._style = {
			...Platform.select({
				ios: {
					shadowOpacity: this._active.interpolate({
						inputRange: [0, 1],
						outputRange: [0, 0.2],
					}),
					shadowRadius: this._active.interpolate({
						inputRange: [0, 1],
						outputRange: [2, 10],
					}),
				},

				android: {
					marginTop: this._active.interpolate({
						inputRange: [0, 1],
						outputRange: [0, 10],
					}),
					marginBottom: this._active.interpolate({
						inputRange: [0, 1],
						outputRange: [0, 10],
					}),
					elevation: this._active.interpolate({
						inputRange: [0, 1],
						outputRange: [2, 6],
					}),
				},
			})
		};
	}

	componentWillReceiveProps(nextProps) {
		if (this.props.active !== nextProps.active) {
			Animated.timing(this._active, {
				duration: 300,
				easing: Easing.bounce,
				toValue: Number(nextProps.active),
			}).start();
		}
	}

	render() {
		const { data } = this.props;
		return (
			<Animated.View
				style={[styles.list_row, this._style]}
			>
				<Icon
					name="drag-handle"
					size={20}
				/>
				<Text style={{ margin: 7 }}>
					{
						(data.closest) ? ('Closest Stop') : (data.name.trim())
					}
				</Text>
			</Animated.View>
		);
	}
}

function mapStateToProps(state, props) {
	return {
		savedStops: state.shuttle.savedStops,
		closestStop: state.shuttle.closestStop
	};
}

function mapDispatchtoProps(dispatch) {
	return {
		orderStops: (newOrder) => {
			dispatch({ type: 'ORDER_STOPS', newOrder });
		}
	};
}

const styles = StyleSheet.create({
	list_row: { backgroundColor: '#FFF', flexDirection: 'row', alignItems: 'center', width: deviceWidth, padding: 7, borderBottomWidth: 1, borderBottomColor: '#EEE' ,
		...Platform.select({
			ios: {
				shadowOpacity: 0,
				shadowOffset: { height: 2, width: 2 },
				shadowRadius: 2,
			},

			android: {
				margin: 0,
				elevation: 0,
			},
		})
	},
});

export default connect(
	mapStateToProps,
	mapDispatchtoProps
)(ShuttleSavedListView);

/*
<ListView
		style={[css.main_container, css.scroll_main, css.whitebg]}
		dataSource={savedDataSource.cloneWithRows(savedStops)}
		renderRow={
			(row, sectionID, rowID) =>
				<SavedItem
					data={row}
					index={rowID}
				/>
		}
	/>
 */