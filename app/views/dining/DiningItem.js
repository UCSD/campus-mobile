import React from 'react';
import {
	View,
	Text,
	StyleSheet,
} from 'react-native';

import DiningHours from './DiningHours';
import Icon from 'react-native-vector-icons/Ionicons';
import { Actions } from 'react-native-router-flux';

import Touchable from '../common/Touchable';
import {
	COLOR_PRIMARY,
	COLOR_BLACK,
	COLOR_LGREY,
	COLOR_MGREY,
	COLOR_DGREY
} from '../../styles/ColorConstants';

const general = require('../../util/general');

const DiningItem = ({ data }) => (
	<View style={styles.rowContainer}>
		<Touchable
			style={styles.rowContainerLeft}
			onPress={() => Actions.DiningDetail({ data })}
		>
			<View>
				<Text style={styles.titleText}>{data.name}</Text>
				<DiningHours
					regularHours={data.regularHours}
					specialHours={data.specialHours}
				/>
			</View>
		</Touchable>

		{data.coords.lat !== 0 ? (
			<Touchable
				style={styles.rowContainerRight}
				onPress={() => general.gotoNavigationApp(data.coords.lat, data.coords.lon)}
			>
				<View style={styles.dl_dir_traveltype_container}>
					<Icon name="md-walk" size={32} color={COLOR_PRIMARY} />
					{data.distanceMilesStr ? (
						<Text style={styles.dl_dir_eta}>{data.distanceMilesStr}</Text>
					) : null }
				</View>
			</Touchable>
		) : null }
	</View>
);

const styles = StyleSheet.create({
	rowContainer: { backgroundColor: COLOR_LGREY, flexDirection: 'row', padding: 10, borderBottomWidth: 1, borderBottomColor: COLOR_MGREY },
	rowContainerLeft: { flex: 6, justifyContent: 'center' },
	titleText: { fontSize: 20, color: COLOR_PRIMARY },
	descriptionText: { fontSize: 12, color: COLOR_DGREY, paddingTop: 1 },
	rowContainerRight: { flex: 1, alignItems: 'flex-end', justifyContent: 'center' },
});

export default DiningItem;
