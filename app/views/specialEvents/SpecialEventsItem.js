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
							numberOfLines={2}
						>
							{specialEventsData['talk-title']}
						</Text>
					) : null }

					<View style={styles.labelView}>
						<Text style={styles.labelText}>{getHumanizedDuration(specialEventsData['start-time'], specialEventsData['end-time'])}</Text>
						{ specialEventsData['talk-type'] === 'Keynote' ? (
							<Text style={styles.labelText}>{specialEventsData['talk-type']}</Text>
						) : null }
						{ specialEventsData.label || specialEventsData['talk-type'] === 'Keynote' ? (
							<Text style={styles.labelText}> - </Text>
						) : null }
						<Text style={styles.labelTextContainer} numberOfLines={1}>
							{ Array.isArray(specialEventsData.label) ? (
								specialEventsData.label.map((item, index) => <Text key={item + index} style={[styles.labelText, { color: Array.isArray(specialEventsData['label-theme']) ? specialEventsData['label-theme'][index] : COLOR_BLACK }]}>{item}</Text>)
							) : null }
						</Text>
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
	itemRow: { flexGrow: 1, flexDirection: 'row', backgroundColor: COLOR_LGREY },
	titleContainer: { flex: 1, marginTop: 3 },
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
