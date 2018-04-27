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
import {
	COLOR_PRIMARY,
	COLOR_DGREY,
	COLOR_WHITE,
	COLOR_MGREY
} from '../../styles/ColorConstants';

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
		if (Array.isArray(this.props.savedStops) && Array.isArray(nextProps.savedStops) &&
			this.props.savedStops.length !== nextProps.savedStops.length) {
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
		if (Array.isArray(this.props.savedStops) && Array.isArray(nextProps.savedStops) &&
			this.props.savedStops.length !== nextProps.savedStops.length) {
			return true;
		} else {
			return false;
		}
	}

	getOrderedArray = () => {
		const orderArray = [];
		if (Array.isArray(this._order)) {
			for (let i = 0; i < this._order.length; ++i) {
				orderArray.push(this.state.savedObject[this._order[i]]);
			}
		}
		return orderArray;
	}

	arrayToObject(array) {
		const savedObject = {};
		if (Array.isArray(array)) {
			for (let i = 0; i < array.length; ++i) {
				savedObject[i] = array[i];
			}
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
					style={css.main_full}
				>
					<Text
						style={styles.addNoticeText}
					>
						To manage your shuttle stops please add a stop.
					</Text>
				</View>
			);
		} else {
			return (
				<SortableList
					style={css.main_full}
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
				style={[styles.listRow, this._style]}
			>
				<Icon
					name="drag-handle"
					size={20}
				/>
				<Text style={styles.nameText}>
					{
						(data.closest) ? ('Closest Stop') : (data.name.trim())
					}
				</Text>
				{
					(data.closest) ? (null) :
					(
						<TouchableOpacity
							onPressOut={() => this._handleRemove(data.id)}
							style={styles.cancelButton}
						>
							<Icon

								name="cancel"
								size={20}
							/>
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
	listRow: { backgroundColor: COLOR_WHITE, flexDirection: 'row', alignItems: 'center', width: deviceWidth, borderBottomWidth: 1, borderBottomColor: COLOR_MGREY , height: 50,
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
	nameText: { flex: 1, margin: 7 },
	cancelButton: { justifyContent: 'center', alignItems: 'center', width: 50, height: 50 },
	addNoticeText: { lineHeight: 28, fontSize: 15, color: COLOR_DGREY, textAlign: 'center' },
});

export default connect(
	mapStateToProps,
	mapDispatchtoProps
)(ShuttleSavedListView);
