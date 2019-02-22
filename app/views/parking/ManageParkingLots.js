import React from 'react'
import {
	View,
	Text,
	Platform,
	Linking,
	ScrollView,
	Animated,
	Easing,
	TouchableOpacity
} from 'react-native'
import SortableList from 'react-native-sortable-list'
import Icon from 'react-native-vector-icons/MaterialIcons'
import { connect } from 'react-redux'
import COLOR from '../../styles/ColorConstants'
import Touchable from '../common/Touchable'
import css from '../../styles/css'


class ManageParkingLots extends React.Component {
	_handleRelease = () => {
		// TODO
	}

	render() {
		const { updateSelectedLots, selectedLots } = this.props
		return (
			<ScrollView style={css.scroll_default} contentContainerStyle={css.main_full}>
				<SortableList
					style={css.main_full_flex}
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
						Where are the other lots?{'\n'}
						{'\n'}
						We are continuously adding parking{'\n'}
						lots and structures to the app!{'\n'}
						{'\n'}
						If you would like to request a specific{'\n'}
						location please mesage us at{'\n'}
						parking@ucsd.edu
					</Text>

					<Touchable
						onPress={() => Linking.openURL('mailto:parking@ucsd.edu')}
						style={css.button_primary}
						text="Email Us"
					>
						<Text style={css.button_primary_text}>Email Us</Text>
					</Touchable>
				</View>
			</ScrollView>
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

		if (selectedLots.includes(data.LocationName)) {
			return (
				<Animated.View style={[css.sslv_listRow, this._style]}>
					<Icon name="drag-handle" size={20} />
					<Text style={css.mpl_row_text_selected}>
						{ data.LocationName }
					</Text>
					<TouchableOpacity
						onPress={() => { updateSelectedLots(false, data.LocationName, selectedLots) }}
						style={css.mpl_row_add_remove_btn}
					>
						{cancelIcon()}
					</TouchableOpacity>
				</Animated.View>
			)
		} else {
			return (
				<Animated.View style={[css.sslv_listRow, this._style]}>
					<Icon name="drag-handle" size={20} />
					<Text style={css.mpl_row_text_unselected}>
						{ data.LocationName }
					</Text>
					<TouchableOpacity
						onPress={() => { updateSelectedLots(true, data.LocationName, selectedLots)}}
						style={css.mpl_row_add_remove_btn}
					>
						{addIcon()}
					</TouchableOpacity>
				</Animated.View>
			)
		}
	}
}

const addIcon = () => (
	<Icon name="add" size={25} color={COLOR.DGREY} />
)
const cancelIcon = () => (
	<Icon name="cancel" size={25} color={COLOR.DGREY} />
)

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
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(ManageParkingLots)