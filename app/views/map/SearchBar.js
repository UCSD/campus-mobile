import React from 'react'
import PropTypes from 'prop-types'
import {
	View,
	TextInput,
	ActivityIndicator,
	StyleSheet,
	Dimensions,
	TouchableOpacity
} from 'react-native'

import Icon from 'react-native-vector-icons/FontAwesome'
import { getPRM } from '../../util/general'
import COLOR from '../../styles/ColorConstants'

const PRM = getPRM()
const windowWidth = Dimensions.get('window').width

class SearchBar extends React.Component {
	constructor(props) {
		super(props)
		this.state = { text: '' }
	}

	render() {
		const {
			reff,
			placeholder,
			update,
			iconStatus,
			style,
			onFocus,
			pressIcon,
			searchInput
		} = this.props

		return (
			<View style={[styles.map_searchbar_container, style]}>
				<TouchableOpacity
					style={styles.icon_container}
					onPress={event => pressIcon()}
				>
					<SearchIcon iconStatus={iconStatus} />
				</TouchableOpacity>
				<TextInput
					ref={reff}
					placeholder={placeholder}
					autoCorrect={false}
					onSubmitEditing={event => update(event.nativeEvent.text.trim())}
					onChangeText={text => this.setState({ text })}
					blurOnSubmit={true}
					returnKeyType="search"
					clearButtonMode="while-editing"
					selectTextOnFocus={true}
					style={styles.map_searchbar_input}
					underlineColorAndroid="rgba(0,0,0,0)"
					onFocus={event => onFocus()}
					onBlur={() => this.setState({ text: searchInput })}
					defaultValue={searchInput}
					value={this.state.text}
					maxLength={35}
				/>
			</View>
		)
	}
}

const SearchIcon = ({ iconStatus }) => {
	switch (iconStatus) {
		case 'load':
			return (
				<ActivityIndicator
					size="small"
				/>
			)
		case 'search':
			return (
				<Icon
					name="search"
					size={Math.round(24 * PRM)}
					color="rgba(0,0,0,.5)"
				/>
			)
		case 'menu':
			return (
				<Icon
					name="bars"
					size={Math.round(24 * PRM)}
					color="rgba(0,0,0,.5)"
				/>
			)
		case 'back':
			return (
				<Icon
					name="arrow-left"
					size={Math.round(24 * PRM)}
					color="rgba(0,0,0,.5)"
				/>
			)
	}
}

SearchBar.propTypes = {
	placeholder: PropTypes.string,
	// update: PropTypes.func,
	searchInput: PropTypes.string
}

SearchBar.defaultProps = {
	placeholder: 'Search here',
	searchInput: ''
}

const styles = StyleSheet.create({
	map_searchbar_container: { zIndex: 2, margin: 6, flexDirection: 'row', position: 'absolute', width: windowWidth - 12, height: 44, borderWidth: 0, borderRadius: 3, backgroundColor: 'white', },
	map_searchbar_input: { flex: 1, height: 44, paddingHorizontal: 4, color: COLOR.VDGREY, fontSize: 20 },
	map_searchbar_icon: { top: 9, left: 8 },
	map_searchbar_ai: { position: 'absolute', top: 12, left: 8 },
	icon_container: { height: 44, justifyContent: 'center', alignSelf: 'center', margin: 8, }
})

export default SearchBar
