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
	const status = dining.getOpenStatus(data.regularHours, data.specialHours);

	const activeDotColor = status.isOpen ?
		COLOR_MGREEN : COLOR_MRED;

	const statusText = status.isOpen ?
		'Open' : 'Closed';

	let soonStatusText = null;
	let soonStatusColor = null;
	if (status.openingSoon) {
		soonStatusText = 'Opening Soon';
		soonStatusColor = COLOR_MGREEN;
	}
	else if (status.closingSoon) {
		soonStatusText = 'Closing Soon';
		soonStatusColor = COLOR_MRED;
	}

	const isClosed = (!status.currentHours);
	const isAlwaysOpen = (
		status.currentHours &&
		status.currentHours.closingHour.format('HHmm') === '2359'
		&& status.currentHours.openingHour.format('HHmm') === '0000'
	);
	const newHourElement = (
		<View>
			<Text style={css.dl_hours_text}>
				{
					(isClosed) ? (
						'Closed'
					) : (
						(isAlwaysOpen) ?
							('Open 24 Hours') :
							(
								status.currentHours.openingHour.format('h:mm a')
								+ ' — '
								+ status.currentHours.closingHour.format('h:mm a')
							)
					)
				}
			</Text>
		</View>
	);

	return (
		<View style={css.dl_row}>
			<Touchable
				style={css.dl_row_container_left}
				onPress={() => { Actions.DiningDetail({ data }); }}
			>
				<View style={css.dl_title_row}>
					<Text style={css.dl_title_text}>{data.name}</Text>
					<View style={css.dl_status_row}>
						<ColoredDot
							size={10}
							color={activeDotColor}
							style={css.dl_status_icon}
						/>
						<Text style={[css.dl_status_text, { color: activeDotColor }]}>
							{statusText}
						</Text>
					</View>
				</View>
				<View style={css.dl_hours_row}>
					{newHourElement}
					<Text
						style={[
							css.dl_status_soon_text,
							{ color: soonStatusColor }
						]}
					>
						{soonStatusText}
					</Text>
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
