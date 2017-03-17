import React from 'react';
import {
	TouchableOpacity,
	StyleSheet
} from 'react-native';
import ElevatedView from 'react-native-elevated-view';
import Icon from 'react-native-vector-icons/FontAwesome';

import { getPRM } from '../../util/general';

const SearchNavButton = ({ visible, onPress }) => (
	(visible) ? (
		<ElevatedView
			style={styles.container}
			elevation={2} // zIndex style and elevation has to match
		>
			<TouchableOpacity
				style={styles.touchable}
				onPress={() => onPress()}
			>
				<Icon name={'location-arrow'} size={20} color={'white'} />
			</TouchableOpacity>
		</ElevatedView>
	) : (<ElevatedView />) // Android bug - breaks view if this is null...on RN39...check if this bug still exists in RN40 or if this can be changed to null
);

const styles = StyleSheet.create({
	container: { zIndex: 2, justifyContent: 'center', alignItems: 'center', position: 'absolute', bottom: (2 * (6 + Math.round(44 * getPRM()))) + 12, right: 6, width: 50, height: 50, borderRadius: 50 / 2, backgroundColor: '#2196F3' },
	touchable: { width: 50, height: 50, borderRadius: 25, alignItems: 'center', justifyContent: 'center' },
});

export default SearchNavButton;
