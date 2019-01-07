import React from 'react'
import { TouchableOpacity } from 'react-native'
import Icon from 'react-native-vector-icons/FontAwesome'
import css from '../../styles/css'

const SearchNavButton = ({ visible, onPress }) => {
	if (visible) {
		return (
			<TouchableOpacity
				style={css.snb_container}
				onPress={() => onPress()}
			>
				<Icon name="location-arrow" size={20} color="white" />
			</TouchableOpacity>
		)
	} else {
		return null
	}
}

export default SearchNavButton
