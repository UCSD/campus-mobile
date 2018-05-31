import React from 'react';
import {
	View,
	Text,
	StyleSheet,
} from 'react-native';
import { withNavigation } from 'react-navigation';
import Icon from 'react-native-vector-icons/Ionicons';
import logger from '../../util/logger';
import Touchable from '../common/Touchable';
import { platformIOS, getHumanizedDuration } from '../../util/general';
import {
	COLOR_DGREY,
	COLOR_MGREY,
	COLOR_LGREY,
	COLOR_BLACK,
	COLOR_YELLOW
} from '../../styles/ColorConstants';
import {
	WINDOW_WIDTH
} from '../../styles/LayoutConstants';

const SpecialEventsItem = ({ navigation, specialEventsData, saved, add, remove, title }) => (
	<View
		style={styles.itemRow}
	>
		<CircleBorder />
		<View style={styles.titleContainer}>
			<Touchable
				onPress={() => navigation.navigate('SpecialEventsDetailView', { data: specialEventsData, title, add, remove })}
			>
				<View>
					{specialEventsData['talk-title'] ? (
						<Text
							style={styles.titleText}
						>
							{specialEventsData['talk-title']}
						</Text>
					) : null }

					<View style={styles.labelView}>
						{ specialEventsData.label ? (
							<Text style={[styles.labelText, { color: specialEventsData['label-theme'] ? specialEventsData['label-theme'] : COLOR_BLACK }]}>{specialEventsData.label}</Text>
						) : null }
						{ specialEventsData['talk-type'] === 'Keynote' ? (
							<Text style={styles.labelText}>{specialEventsData['talk-type']}</Text>
						) : null }
						{ specialEventsData.label || specialEventsData['talk-type'] === 'Keynote' ? (
							<Text style={styles.labelText}> - </Text>
						) : null }
						<Text style={styles.labelText}>{getHumanizedDuration(specialEventsData['start-time'], specialEventsData['end-time'])}</Text>
					</View>
				</View>
			</Touchable>
		</View>

		{ (add !== null) ? (
			<Touchable style={styles.starButton} onPress={() => (
				(saved) ? (
					removeSession(remove, specialEventsData.id, specialEventsData['talk-title'])
				) : (
					addSession(add, specialEventsData.id, specialEventsData['talk-title'])
				)
			)}>
				<View style={styles.starButtonInner}>
					<Icon
						name={'ios-star-outline'}
						size={32}
						style={styles.starOuterIcon}
					/>
					{ saved ? (
						<Icon
							name={'ios-star'}
							size={26}
							style={styles.starInnerIcon}
						/>
					) : null }
				</View>
			</Touchable>
		) : null }
	</View>
);

const CircleBorder = () => (
	<View style={styles.borderContainer}>
		<View style={styles.line} />
		<View style={styles.circle} />
	</View>
);

const removeSession = (remove, id, title) => {
	remove(id);
	logger.trackEvent('Special Events', 'Session Removed: ' + title)
}

const addSession = (add, id, title) => {
	add(id);
	logger.trackEvent('Special Events', 'Session Added: ' + title)
}

const styles = StyleSheet.create({
	itemRow: { flexShrink: 1, flexDirection: 'row', paddingBottom: 10 },
	titleContainer: { flexShrink: 1, flexBasis: 10000, marginTop: 3 }, // TODO: improve usage of flex, especially to avoid hardcoding 10000, which acts like an infifity value to maximize column width on all screen sizes.
	titleText: { alignSelf: 'stretch', fontSize: 17, color: 'black' },
	labelView: { flexDirection: 'row', paddingTop: 4 },
	labelTextContainer: { 'flexDirection': 'row', 'maxWidth': WINDOW_WIDTH / 2, },
	labelText: { fontSize: 13 },
	starButton: { width: 50 },
	starButtonInner: { justifyContent: 'flex-start', alignItems: 'center' },
	starOuterIcon: { color: COLOR_DGREY, position: platformIOS() ? 'absolute' : 'relative', zIndex: 10, backgroundColor: 'rgba(0,0,0,0)' },
	starInnerIcon: { color: COLOR_YELLOW, position: 'absolute', zIndex: platformIOS() ? 5 : 15, marginTop: 3 },
	borderContainer: { width: 1, alignSelf: 'stretch', marginRight: 10, alignItems: 'flex-start' },
	line: { flexGrow: 1, borderLeftWidth: 1, borderColor: COLOR_MGREY, paddingBottom: 20 },
	circle: { position: 'absolute', top: 11, left: -2.5, height: 6, width: 6, borderRadius: 3, borderWidth: 1, borderColor: COLOR_MGREY, backgroundColor: COLOR_LGREY },
});

const wrappedSpecialEventsItem = withNavigation(SpecialEventsItem);

export default wrappedSpecialEventsItem;
