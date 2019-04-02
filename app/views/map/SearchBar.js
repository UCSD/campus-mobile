import React from 'react'
import { View, TextInput, ActivityIndicator, TouchableOpacity } from 'react-native'
import Icon from 'react-native-vector-icons/FontAwesome'
import css from '../../styles/css'

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
			<View style={[css.map_searchbar_container, style]}>
				<TouchableOpacity
					style={css.map_searchbar_icon_container}
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
					style={css.map_searchbar_input}
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
		case 'load': 	return (<ActivityIndicator size="small" />)
		case 'search':	return (<Icon name="search" size={24} color="rgba(0,0,0,.5)" />)
		case 'menu':	return (<Icon name="bars" size={24} color="rgba(0,0,0,.5)" />)
		case 'back':	return (<Icon name="arrow-left" size={24} color="rgba(0,0,0,.5)" />)
	}
}

SearchBar.defaultProps = {
	placeholder: 'Search here',
	searchInput: ''
}

export default SearchBar
