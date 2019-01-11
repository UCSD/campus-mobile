import React from 'react'
import { TouchableOpacity } from 'react-native'
import Icon from 'react-native-vector-icons/FontAwesome'
import css from '../../styles/css'
import COLOR from '../../styles/ColorConstants'

const SearchShuttleIcon = ({ visible, onPress }) => {
	if (visible) {
		return (
			<TouchableOpacity
				onPress={() => onPress()}
				style={css.snb_container}
			>
				<Icon name="bus" size={20} color={COLOR.WHITE} />
			</TouchableOpacity>
		)
	} else {
		return null
	}
}

export default SearchShuttleIcon
