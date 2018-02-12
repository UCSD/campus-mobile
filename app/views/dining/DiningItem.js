import React from 'react';
import {
	View,
	Text,
} from 'react-native';
import { Actions } from 'react-native-router-flux';
import Icon from 'react-native-vector-icons/Ionicons';

import ColoredDot from '../common/ColoredDot';
import Touchable from '../common/Touchable';
import {
	COLOR_PRIMARY,
	COLOR_MGREEN,
	COLOR_MRED
} from '../../styles/ColorConstants';
import css from '../../styles/css';

const general = require('../../util/general');
const dining = require('../../util/dining');

const DiningItem = ({ data }) => {
	if (!data.id) return null;
	const activeDotColor = dining.getOpenStatus(data.regularHours, data.specialHours) ?
		COLOR_MGREEN : COLOR_MRED;

	return (
		<View style={css.dining_list_row}>
			<ColoredDot
				size={10}
				color={activeDotColor}
				style={css.dining_hours_dot}
			/>
			<Touchable
				style={css.dl_row_container_left}
				onPress={() => Actions.DiningDetail({ data })}
			>
				<View>
					<Text style={css.dl_title_text}>{data.name}</Text>
				</View>
			</Touchable>

			{data.coords.lat !== 0 ? (
				<Touchable
					style={css.dl_row_container_right}
					onPress={() => general.gotoNavigationApp(data.coords.lat, data.coords.lon)}
				>
					<View style={css.dl_dir_traveltype_container}>
						<Icon name="md-walk" size={32} color={COLOR_PRIMARY} />
						{data.distanceMilesStr ? (
							<Text style={css.dl_dir_eta}>{data.distanceMilesStr}</Text>
						) : null }
					</View>
				</Touchable>
			) : null }
		</View>
	);
};

export default DiningItem;
