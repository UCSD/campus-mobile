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


class ManageParkingLots extends React.Component {
	componentWillMount() {
		const parkingLots = this.props.parkingData
		this.setState({ parkingLots })
	}

	componentWillReceiveProps(nextProps) {

		if (this.props.selectedLots.length !== nextProps.selectedLots.length) {
			const { selectedLots } = this.props
			this.setState({ selectedLots })
		}
	}

	shouldComponentUpdate(nextProps, nextState) {
		if (this.props.selectedLots.length !== nextProps.selectedLots.length) {
			return true
		} else {
			return false
		}
	}

	getOrderedArray = () => {
		const orderArray = []
		if (Array.isArray(this._order)) {
			for (let i = 0; i < this._order.length; ++i) {
				orderArray.push(this.state.parkingLots[this._order[i]])
			}
		}
		return orderArray
	}

	_handleRelease = () => {
		if (this._order) {
			const orderedParkingLots = this.getOrderedArray()
			this.props.reorderParkingLots(orderedParkingLots)
		}
	}

	render() {
		const { updateSelectedLots, selectedLots } = this.props
		return (
			<View style={css.main_full_flex}>
				<SortableList
					style={css.flex}
					data={this.props.parkingData}
					renderRow={
						({ data, active, disabled }) => (
							<ListItem
								data={data}
								active={active}
								selectedLots={selectedLots}
								updateSelectedLots={updateSelectedLots}
							/>
						)}
					onChangeOrder={(nextOrder) => { this._order = nextOrder }}
					onReleaseRow={key => this._handleRelease()}
				/>
				<View style={css.mpl_message_view}>
					<Text style={css.mpl_message_text}>
						Where are the other lots?{'\n\n'}
						We are continuously adding parking lots and structures to the app!{'\n\n'}
						If you would like to request a specific location please mesage us at parking@ucsd.edu
					</Text>
				</View>
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

	render() {
		const { data, selectedLots, updateSelectedLots } = this.props

		return (
			<Animated.View style={[css.sl_row, this._style]}>
				<Icon style={css.sl_icon} name="drag-handle" size={20} />
				<Text style={[css.sl_title, !selectedLots.includes(data.LocationName) ? css.sl_title_disabled : null]}>
					{ data.LocationName }
				</Text>
				<TouchableOpacity
					onPress={() => { updateSelectedLots(!selectedLots.includes(data.LocationName), data.LocationName, selectedLots) }}
					style={css.sl_switch_container}
				>
					{selectedLots.includes(data.LocationName) ? (
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
	parkingData: state.parking.parkingData,
	selectedLots: state.parking.selectedLots
})

const mapDispatchToProps = dispatch => (
	{
		updateSelectedLots: (add, name, selectedLots) => {
			dispatch({ type: 'UPDATE_PARKING_LOT_SELECTIONS', add, name, selectedLots })
		},
		renderWarning: (showWarning) => {
			dispatch({ type: 'SET_WARNING_SIGN', showWarning })
		},
		reorderParkingLots: (newParkingData) => {
			dispatch({ type: 'SET_PARKING_DATA', newParkingData })
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(ManageParkingLots)