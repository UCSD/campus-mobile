import React from 'react'
import {
	View,
	Text,
	Platform,
	Animated,
	Easing,
	TouchableOpacity
} from 'react-native'
import SortableList from 'react-native-sortable-list'
import Icon from 'react-native-vector-icons/MaterialIcons'
import { connect } from 'react-redux'
import COLOR from '../../styles/ColorConstants'
import css from '../../styles/css'

class ManageOccuspaceLocations extends React.Component {
	shouldComponentUpdate(nextProps, nextState) {
		if (this.props.selectedLocations.length !== nextProps.selectedLocations.length) {
			return true
		} else {
			return false
		}
	}
	getOrderedArray = () => {
		const orderArray = []
		if (Array.isArray(this._order)) {
			for (let i = 0; i < this._order.length; ++i) {
				orderArray.push(this.props.occuspaceData[this._order[i]])
			}
		}
		return orderArray
	}

	_handleRelease = () => {
		if (this._order) {
			this.props.reorderOccuspaceLocations(this.getOrderedArray())
		}
	}

	render() {
		const { addLocation, removeLocation, selectedLocations, occuspaceData } = this.props
		return (
			<View style={css.main_full_flex}>
				<SortableList
					style={css.flex}
					data={occuspaceData}
					renderRow={
						({ data, active, disabled }) => (
							<ListItem
								data={data}
								active={active}
								addLocation={addLocation}
								removeLocation={removeLocation}
								selectedLocations={selectedLocations}
							/>
						)}
					onChangeOrder={(nextOrder) => { this._order = nextOrder }}
					onReleaseRow={key => this._handleRelease()}
				/>
			</View>
		)
	}
}

class ListItem extends React.Component {
	constructor(props) {
		super(props)

		this._active = new Animated.Value(0)

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
		}
	}

	componentWillReceiveProps(nextProps) {
		if (this.props.active !== nextProps.active) {
			Animated.timing(this._active, {
				duration: 300,
				easing: Easing.bounce,
				toValue: Number(nextProps.active),
			}).start()
		}
	}

	shouldComponentUpdate(nextProps, nextState) {
		if (this.props.selectedLocations.length !== nextProps.selectedLocations.length) {
			return true
		} else {
			return false
		}
	}

	render() {
		const { data, selectedLocations, addLocation, removeLocation } = this.props
		const isSelected = selectedLocations.includes(data.locationName)
		return (
			<Animated.View style={[css.sl_row, this._style]}>
				<Icon style={css.sl_icon} name="drag-handle" size={20} />
				<Text style={[css.sl_title, !isSelected ? css.sl_title_disabled : null]}>
					{ data.locationName }
				</Text>
				<TouchableOpacity
					onPress={() => { isSelected ? removeLocation(data.locationName, selectedLocations) : addLocation(data.locationName, selectedLocations) }}
					style={css.sl_switch_container}
				>
					{isSelected ? (
						<Icon name="remove" size={24} color={COLOR.DGREY} />
					) : (
						<Icon name="add" size={24} color={COLOR.DGREY} />
					)}
				</TouchableOpacity>
			</Animated.View>
		)
	}
}

const mapStateToProps = state => ({
	occuspaceData: state.occuspace.data,
	selectedLocations: state.occuspace.selectedLocations,
})

const mapDispatchToProps = dispatch => (
	{
		addLocation: (locationName, selectedLocations) => {
			dispatch({ type: 'SET_SELECTED_OCCUSPACE_LOCATIONS', add: true, name: locationName, selectedLocations })
		},
		removeLocation: (locationName, selectedLocations) => {
			dispatch({ type: 'SET_SELECTED_OCCUSPACE_LOCATIONS', add: false, name: locationName, selectedLocations })
		},
		reorderOccuspaceLocations: (newOrder) => {
			dispatch({ type: 'SET_ORDER_OCCUSAPCE_DATA', newOrder })
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(ManageOccuspaceLocations)