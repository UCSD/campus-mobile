import React from 'react';
import {
	TouchableOpacity,
	StyleSheet,
	Text,
	Dimensions,
} from 'react-native';
import ElevatedView from 'react-native-elevated-view';

import { getPRM } from '../../util/general';

const deviceWidth = Dimensions.get('window').width;

const SearchResultsBar = ({ visible, onPress }) => (
	(visible) ? (
		<ElevatedView
			style={styles.bottomBarContainer}
			elevation={5}
		>
			<TouchableOpacity
				style={styles.bottomBarContent}
				onPress={() => onPress()}
			>
				<Text
					style={styles.bottomBarText}
				>
					See More Results
				</Text>
			</TouchableOpacity>
		</ElevatedView>
		) : (null)
);

const styles = StyleSheet.create({
	bottomBarContainer: { zIndex: 5, alignItems: 'center', justifyContent: 'center', position: 'absolute', bottom: 0, width: deviceWidth, height: Math.round(44 * getPRM()), borderWidth: 0, backgroundColor: 'white', },
	bottomBarContent: { flex: 1, justifyContent: 'center', alignSelf: 'stretch' },
	bottomBarText: { textAlign: 'center', },
});

export default SearchResultsBar;
