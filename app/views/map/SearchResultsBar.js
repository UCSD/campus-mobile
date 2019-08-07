import React from 'react'
import { View, TouchableOpacity, Text } from 'react-native'
import css from '../../styles/css'

const SearchResultsBar = ({ visible, onPress }) => {
	if (visible) {
		return (
			<View style={css.srb_bottomBarContainer}>
				<TouchableOpacity
					style={css.srb_bottomBarContent}
					onPress={() => onPress()}
				>
					<Text style={css.srb_bottomBarText}>
						See More Results
					</Text>
				</TouchableOpacity>
			</View>
		)
	} else {
		return (null)
	}
}

export default SearchResultsBar
