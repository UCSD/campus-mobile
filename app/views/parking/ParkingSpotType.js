import React from 'react'
import {
	View,
	Text,
	FlatList,
} from 'react-native'
import ElevatedView from 'react-native-elevated-view'
import Icon from 'react-native-vector-icons/MaterialIcons'
import { connect } from 'react-redux'
import COLOR from '../../styles/ColorConstants'
import Touchable from '../common/Touchable'
import css from '../../styles/css'

const ParkingTypes = require('./ParkingSpotTypeList.json')

class ParkingSpotType extends React.Component {
	rowTouched(index) {
		const { isChecked, updateSelectedTypes, count } = this.props
		const ids = [...isChecked]
		// user is trying to unselect a row
		if (ids[index]) {
			ids[index] = !ids[index]
			updateSelectedTypes(ids, count - 1)
		}
		// user is trying to select a row
		else if (count < 3) {
			ids[index] = !ids[index]
			updateSelectedTypes(ids, count + 1)
		}
		// user tried to select a row but reached limit, so do nothing
	}

	// this function returns a touchable that has all the elements needed for each row
	// also decides if the row is selected or unselcted based on the state
	renderRow(parkingObj) {
		const { id } = parkingObj
		const { isChecked } = this.props
		return (
			<Touchable
				onPress={() => this.rowTouched(id)}
			>
				{isChecked[id] ? getSelectedRow({ parkingObj }) : getUnselectedRow({ parkingObj })}
			</Touchable>
		)
	}
	// TODO
	renderSeparator({ leadingItem, highlighted, props }) {
		//console.log(props)
		return (
			<View
				style={css.pst_flat_list_separator}
			/>
		)
	}

	render() {
		return (
			<View
				style={css.pst_full_container}
			>
				<FlatList
					style={css.pst_flat_list}
					scrollEnabled={false}
					showsVerticalScrollIndicator={false}
					keyExtractor={parkingType => parkingType.id.toString()}
					data={ParkingTypes}
					extraData={this.props.isChecked}
					renderItem={
						(parkingObj, separators) => {
							parkingObj = parkingObj.item
							return this.renderRow(parkingObj)
						}
					}
					enableEmptySections={true}
					ItemSeparatorComponent={this.renderSeparator}
				/>
				{displayWarning()}
			</View>
		)
	}
}

// returns the warning sign
const displayWarning = () =>  (
	<ElevatedView
		style={css.pst_warning_elevated_view}
		elevation={5}
	>
		<View style={css.pst_warning_conatiner_view}>
			<Text style={css.pst_warning_header_text} >
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
		<ElevatedView style={css.pst_elevated_row_view} elevation={5}>
			<View style={[css.pst_circle, { backgroundColor }]}>
				<Text
					style={[css.pst_character, { color: textColor }]}
					allowFontScaling={false}
				>
					{shortName || accessibleIcon()}
				</Text>
			</View>
			<Text
				style={css.pst_row_text}
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
		<View style={css.pst_unelevated_row_view}>
			<View style={[css.pst_circle, { backgroundColor }]}>
				<Text
					style={[css.pst_character, { color: textColor }]}
					allowFontScaling={false}
				>
					{shortName || accessibleIcon()}
				</Text>
			</View>
			<Text
				style={css.pst_row_text}
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

// export default ParkingSpotType
const mapStateToProps = state => ({
	isChecked: state.parking.isChecked,
	count: state.parking.count
})


const mapDispatchToProps = dispatch => (
	{
		updateSelectedTypes: (isChecked, count) => {
			dispatch({ type: 'SET_PARKING_TYPE_SELECTION', isChecked, count })
		},
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(ParkingSpotType)
