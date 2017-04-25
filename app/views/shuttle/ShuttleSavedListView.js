import React from 'react';
import {
	Text,
	StyleSheet,
	Dimensions,
	Animated,
	Platform,
	Easing,
	TouchableOpacity,
	View
} from 'react-native';
import SortableList from 'react-native-sortable-list';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { connect } from 'react-redux';
import Toast from 'react-native-simple-toast';

import css from '../../styles/css';
import { getCampusPrimary } from '../../util/general';

const deviceWidth = Dimensions.get('window').width;

class ShuttleSavedListView extends React.Component {
	componentWillMount() {
		const savedStops = this.props.savedStops.slice();
		const { closestStop } = this.props;
		if (closestStop) {
			savedStops.splice(closestStop.savedIndex, 0, closestStop); // insert closest
		}
		const savedObject = this.arrayToObject(savedStops);
		this.setState({ savedObject });
	}

	componentWillReceiveProps(nextProps) {

		if (this.props.savedStops.length !== nextProps.savedStops.length) {
			const savedStops = nextProps.savedStops.slice();
			const { closestStop } = nextProps;
			if (closestStop) {
				savedStops.splice(closestStop.savedIndex, 0, closestStop); // insert closest
			}
			const savedObject = this.arrayToObject(savedStops);
			this.setState({ savedObject });
		}
	}

	shouldComponentUpdate(nextProps, nextState) {
		if (this.props.savedStops.length !== nextProps.savedStops.length) {
			return true;
		} else {
			return false;
		}
	}

	getOrderedArray = () => {
		const orderArray = [];
		for (let i = 0; i < this._order.length; ++i) {
			orderArray.push(this.state.savedObject[this._order[i]]);
		}
		return orderArray;
	}

	arrayToObject(array) {
		const savedObject = {};
		for (let i = 0; i < array.length; ++i) {
			savedObject[i] = array[i];
		}
		return savedObject;
	}

	_handleRelease = () => {
		if (this._order) {
			const orderedStops = this.getOrderedArray();
			this.props.orderStops(orderedStops);
		}
	}

	render() {
		const { removeStop } = this.props;

		if (Object.keys(this.state.savedObject).length < 1) {
			return (
				<View
					style={[css.main_container, css.whitebg]}
				>
					<Text
						style={styles.add_notice}
					>
						To manage your shuttle stops please add a stop.
					</Text>
					<TouchableOpacity
						style={styles.add_container}
						onPress={() => this.props.gotoRoutesList()}
					>
						<Text style={styles.add_text}>Add a Stop</Text>
					</TouchableOpacity>
				</View>
			);
		} else {
			return (
				<View
					style={[css.main_container, css.whitebg]}
				>
					<SortableList
						data={this.state.savedObject}
						renderRow={
							({ data, active, disabled }) =>
								<SavedItem
									data={data}
									active={active}
									removeStop={removeStop}
								/>
						}
						onChangeOrder={(nextOrder) => { this._order = nextOrder; }}
						onReleaseRow={(key) => this._handleRelease()}
					/>
					<TouchableOpacity
						style={styles.add_container}
						onPress={() => this.props.gotoRoutesList()}
					>
						<Text style={styles.add_text}>Add a Stop</Text>
					</TouchableOpacity>
				</View>
			);
		}
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

	_handleRemove = (stopID) => {
		this.props.removeStop(stopID);
		Toast.showWithGravity(this.props.data.name.trim() + ' removed.', Toast.SHORT, Toast.CENTER);
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
				<Text style={styles.name_text}>
					{
						(data.closest) ? ('Closest Stop') : (data.name.trim())
					}
				</Text>
				{
					(data.closest) ? (null) :
					(
						<TouchableOpacity
							onPress={() => this._handleRemove(data.id)}
						>
							<View
								style={styles.cancel_container}
							>
								<Icon
									name="cancel"
									size={20}
								/>
							</View>
						</TouchableOpacity>
					)
				}
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
		},
		removeStop: (stopID) => {
			dispatch({ type: 'REMOVE_STOP', stopID });
		}
	};
}

const styles = StyleSheet.create({
	list_row: { backgroundColor: '#FFF', flexDirection: 'row', alignItems: 'center', width: deviceWidth, borderBottomWidth: 1, borderBottomColor: '#EEE' , height: 50,
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
	name_text: { flex: 1, margin: 7 },
	cancel_container: { justifyContent: 'center', alignItems: 'center', width: 50, height: 50 },
	add_notice: { lineHeight: 28, fontSize: 15, color: '#444', textAlign: 'center' },
	add_container: { flexDirection: 'row', margin: 7, justifyContent: 'center', alignItems: 'center' },
	add_text: { flexGrow: 1, color: getCampusPrimary(), fontSize: 20, paddingLeft: 8, textAlign: 'center' },
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