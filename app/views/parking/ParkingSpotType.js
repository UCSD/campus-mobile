import React from 'react'
import {
	View,
	Text,
	FlatList,
	ScrollView
} from 'react-native'
import ElevatedView from 'react-native-elevated-view'
import Icon from 'react-native-vector-icons/MaterialIcons'
import { connect } from 'react-redux'
import COLOR from '../../styles/ColorConstants'
import Touchable from '../common/Touchable'
import css from '../../styles/css'

const campusLogo = require('../../assets/images/UCSanDiegoLogo-White.png')
const ParkingTypes = require('./ParkingSpotTypeList.json')

class ParkingSpotType extends React.Component {
	constructor(props) {
		super(props)
		this.state = { isChecked: [false, false, false, false, false], count: 0 }
	}

	incrementCount() {
		this.setState({ count: this.state.count + 1 })
	}

	decrementCount() {
		this.setState({ count: this.state.count - 1 })
	}


	rowTouched(index) {
		const ids = [...this.state.isChecked]
		// user is trying to unselect a row
		if (ids[index]) {
			ids[index] = !ids[index]
			this.setState({ isChecked: ids })
			this.decrementCount()
		}
		// user is trying to select a row
		else if (this.state.count < 3) {
			ids[index] = !ids[index]
			this.setState({ isChecked: ids })
			this.incrementCount()
		}
		// user tried to select a row but reached limit, so do nothing
	}

	// this function returns a touchable that has all the elements needed for each row
	// also decides if the row is selected or unselcted based on the state
	renderRow(parkingObj) {
		const { id } = parkingObj
		return (
			<Touchable
				onPress={() => this.rowTouched(id)}
			>
				{this.state.isChecked[id] ? getSelectedRow({ parkingObj }) : getUnselectedRow({ parkingObj })}
			</Touchable>
		)
	}

	render() {
		return (
			<View
				style={Styles.fullContainer}
			>
				<FlatList
					style={Styles.flatList}
					scrollEnabled={false}
					showsVerticalScrollIndicator={false}
					keyExtractor={parkingType => parkingType.id.toString()}
					data={ParkingTypes}
					extraData={this.state.isChecked}
					renderItem={
						(parkingObj) => {
							parkingObj = parkingObj.item
							return this.renderRow(parkingObj)
						}
					}
					enableEmptySections={true}
				/>
				{displayWarning()}
			</View>
		)
	}
}

const renderSeparator = () => (
	<View
		style={Styles.flatListSeperator}
	/>
)
// returns the warning sign
const displayWarning = () =>  (
	<ElevatedView
		style={Styles.warningElevatedView}
		elevation={5}
	>
		<View style={Styles.waringContainerView}>
			<Text style={Styles.warningHeaderTextStyle} >
				{'Max Selection (3)'}
			</Text>
			<Text>
				{'Only up to 3 type selections'}
			</Text>
			<Text>
				{'are allowed at one time.'}
			</Text>
			<Text>
				{'\nCancel a parking type selection to'}
			</Text>
			<Text>
				{'add another parking type.'}
			</Text>
		</View>
	</ElevatedView>
)


// returns an elevated view that contains all elemnts of a selected row
function getSelectedRow({ parkingObj }) {
	const { type, textColor, backgroundColor, shortName } = parkingObj
	return (
		<ElevatedView style={Styles.elevatedRowView} elevation={5}>
			<View style={[css.ssl_circle, { backgroundColor }]}>
				<Text
					style={[css.ssl_shortNameText, { color: textColor }]}
					allowFontScaling={false}
				>
					{shortName || accessibleIcon()}
				</Text>
			</View>
			<Text
				style={[css.sslv_row_name, { paddingLeft: 10 }]}
			>
				{type}
			</Text>
			{checkedIcon()}
		</ElevatedView>
	)
}
// returns a view containing an unslected row
function getUnselectedRow({ parkingObj }) {
	const { type, textColor, backgroundColor, shortName } = parkingObj
	return (
		<View style={Styles.unelevatedRowView}>
			<View style={[css.ssl_circle, { backgroundColor }]}>
				<Text
					style={[css.ssl_shortNameText, { color: textColor }]}
					allowFontScaling={false}
				>
					{shortName || accessibleIcon()}
				</Text>
			</View>
			<Text
				style={[css.sslv_row_name, { paddingLeft: 10 }]}
			>
				{type}
			</Text>
			{uncheckedIcon()}
		</View>
	)
}

const accessibleIcon = () => (
	<Icon name="accessible" size={25} color="white" />
)

const checkedIcon = () => (
	<Icon name="check" size={25} color={COLOR.DGREY} style={{ paddingRight: 20 }} />
)

const uncheckedIcon = () => (
	<Icon name="check" size={25} color={COLOR.MGREY} style={{ paddingRight: 20 }} />
)

const Styles = {
	elevatedRowView: {
		flexDirection: 'row',
		flex: 1,
		paddingLeft: 15,
		backgroundColor: COLOR.MGREY,
		alignItems: 'center',
		justifyContent: 'center',
		height: 50,
		margin: 3,

	},
	unelevatedRowView: {
		flexDirection: 'row',
		flex: 1,
		paddingLeft: 15,
		backgroundColor: 'white',
		alignItems: 'center',
		justifyContent: 'center',
		height: 50,
		margin: 3,
	},
	warningElevatedView: {
		flex: 1,
		flexDirection: 'row',
		backgroundColor: 'white' ,
		alignItems: 'center',
		justifyContent: 'center',
		marginHorizontal: 30,
		bottom: 25
	},
	warningConatinerView: {
		alignItems: 'center',
		justifyContent: 'center'
	},
	warningHeaderTextStyle: {
		fontSize: 18,
		top: -20,
		alignItems: 'center'
	},
	fullContainer: {
		flex: 1,
		backgroundColor: 'white'
	},
	flatList: { backgroundColor: 'white' },
	flatListSeperator: {
		height: 1,
		backgroundColor: COLOR.MGREY,
	}
}


export default ParkingSpotType
