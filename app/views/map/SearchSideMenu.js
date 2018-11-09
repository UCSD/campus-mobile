import React, { PropTypes } from 'react'
import { Text, ScrollView, View, Switch } from 'react-native'

const SearchSideMenu = ({ onToggle, toggles, shuttle_routes }) => (
	<ScrollView scrollsToTop={false}>
		<View>
			{Object.keys(shuttle_routes).map((key, index) => {
				const uniqueKey = key + index
				return (
					<View key={uniqueKey}>
						<Text>{shuttle_routes[key].name.trim()}</Text>
						<Switch
							onValueChange={val => onToggle(val, key)}
							value={toggles[key]}
						/>
					</View>
				)
			})}
		</View>
	</ScrollView>
)

SearchSideMenu.propTypes = {
	toggles: PropTypes.object,
	shuttle_routes: PropTypes.object,
}

SearchSideMenu.defaultProps = { shuttle_routes: null }
export default SearchSideMenu
