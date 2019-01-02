import React, { PropTypes } from 'react';
import {
	Text,
	ScrollView,
	View,
	Switch
} from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';

import general from '../../util/general';

const SearchSideMenu = ({ onToggle, toggles, shuttle_routes }) => (
	<ScrollView scrollsToTop={false}>
		<View>
			{
				// Create switch for every shuttle route
				Object.keys(shuttle_routes).map((key, index) => (
					<View key={key+index}>
						<Text>{shuttle_routes[key].name.trim()}</Text>
						<Switch
							onValueChange={(val) => onToggle(val, key)}
							value={toggles[key]}
						/>
					</View>
					)
				)
			}
		</View>
	</ScrollView>
);

SearchSideMenu.propTypes = {
	toggles: PropTypes.object,
	shuttle_routes: PropTypes.object,
};

SearchSideMenu.defaultProps = {
	shuttle_routes: null,
};

export default SearchSideMenu;
