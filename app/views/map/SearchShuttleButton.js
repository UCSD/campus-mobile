import React from 'react';
import {
	TouchableOpacity,
	StyleSheet
} from 'react-native';
import ElevatedView from 'react-native-elevated-view';
import Icon from 'react-native-vector-icons/FontAwesome';
import { COLOR_PIN } from '../../styles/ColorConstants';
import { getPRM } from '../../util/general';

const SearchShuttleIcon = ({ visible, onPress }) => (
	(visible) ? (
		<ElevatedView
			style={styles.container}
			elevation={2} // zIndex style and elevation has to match
		>
			<TouchableOpacity
				onPress={() => onPress()}
				style={styles.touchable}
			>
				<Icon name={'bus'} size={20} color={'white'} />
			</TouchableOpacity>
		</ElevatedView>
	) : (<ElevatedView />) // Android bug
);

const styles = StyleSheet.create({
	container: { zIndex: 2, justifyContent: 'center', alignItems: 'center', position: 'absolute', bottom: 6 + Math.round(44 * getPRM()), right: 6, width: 50, height: 50, borderRadius: 50 / 2, backgroundColor: COLOR_PIN },
	touchable: { width: 50, height: 50, borderRadius: 25, alignItems: 'center', justifyContent: 'center' },
});

export default SearchShuttleIcon;
