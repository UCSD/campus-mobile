import React from 'react'
import { View, Text, FlatList, Linking, ScrollView } from 'react-native'
import Icon from 'react-native-vector-icons/MaterialIcons'
import { connect } from 'react-redux'
import COLOR from '../../styles/ColorConstants'
import Touchable from '../common/Touchable'
import css from '../../styles/css'

class ManageParkingLots extends React.Component {
	renderRow(parkingLot) {
		const { LocationName } = parkingLot.item
		const { updateSelectedLots, selectedLots } = this.props

		if (selectedLots.includes(LocationName)) {
			return (
				<View style={css.mpl_row_view}>
					<Text style={css.mpl_row_text_selected}>
						{LocationName}
					</Text>
					<Touchable
						onPress={() => {
							updateSelectedLots(false, LocationName, selectedLots)
						}}
						style={css.mpl_row_add_remove_btn}
					>
						{cancelIcon()}
					</Touchable>
				</View>
			)
		} else {
			return (
				<View style={css.mpl_row_view}>
					<Text style={css.mpl_row_text_unselected}>
						{LocationName}
					</Text>
					<Touchable
						onPress={() => {
							updateSelectedLots(true, LocationName, selectedLots)
						}}
						style={css.mpl_row_add_remove_btn}
					>
						{addIcon()}
					</Touchable>
				</View>
			)
		}
	}

	render() {
		return (
			<ScrollView style={css.scroll_default} contentContainerStyle={css.main_full}>
				<FlatList
					style={css.mpl_flat_list_container}
					scrollEnabled={false}
					showsVerticalScrollIndicator={false}
					keyExtractor={parkingLot => parkingLot.LocationId}
					data={this.props.parkingData}
					renderItem={parkingLot => this.renderRow(parkingLot)}
					ItemSeparatorComponent={renderSeparator}
					ListFooterComponent={renderSeparator}
					ListHeaderComponent={renderSeparator}
					extraData={this.props.selectedLots}
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
const addIcon = () => (
	<Icon name="add" size={25} color={COLOR.DGREY} />
)
const cancelIcon = () => (
	<Icon name="cancel" size={25} color={COLOR.DGREY} />
)
const renderSeparator = () => (
	<View style={css.pst_flat_list_separator} />
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