import React from 'react';
import PropTypes from 'prop-types';
import {
	View,
	Text,
	StyleSheet
} from 'react-native';

import Touchable from './Touchable';
import SafeImage from './SafeImage';
import {
	MAX_CARD_WIDTH
} from '../../styles/LayoutConstants';
import {
	COLOR_BLACK,
	COLOR_DGREY,
	COLOR_MGREY,
	COLOR_LGREY,
	COLOR_PRIMARY
} from '../../styles/ColorConstants';

/**
 * Generic row item
 * @param  {Object} data
 * @param {Boolean} card Display using card style
 * @param {Function} onPress
 * @return {JSX}
 * @todo  Standardize and make this more generic/applicable?
 */
const DataItem = ({ data, card, onPress }) => (
	(card) ?
	(
		<Touchable
			onPress={() => onPress(data)}
			style={styles.cardMain}
		>
			<Text style={styles.cardTitleText}>{data.title}</Text>
			<View style={styles.cardInfoContainer}>
				<View style={styles.descContainer}>
					{data.description ? (<Text style={styles.descText} numberOfLines={3}>{data.description}</Text>) : null }
					<Text style={styles.dateText}>{data.subtext}</Text>
				</View>
				<SafeImage style={styles.image} source={{ uri: data.image }} />
			</View>
		</Touchable>
	) :
	(
		<Touchable
			onPress={() => onPress(data)}
			style={styles.touchableRow}
		>
			<Text
				style={styles.titleText}
				numberOfLines={1}
			>
				{data.title}
			</Text>
			<View style={styles.listInfoContainer}>
				<View style={styles.descContainer}>
					{data.description ? (
						<Text
							style={styles.descText}
							numberOfLines={3}
						>
							{data.description.trim()}
						</Text>
					) : null }
					<Text style={styles.dateText}>{data.subtext}</Text>
				</View>
				<SafeImage style={styles.image} source={{ uri: data.image }} />
			</View>
		</Touchable>
	)
);

DataItem.propTypes = {
	data: PropTypes.object.isRequired,
	card: PropTypes.bool,
	onPress: PropTypes.func,
};

DataItem.defaultProps = {
	card: false
};

const styles = StyleSheet.create({
	cardMain: { borderWidth: 1, borderRadius: 2, borderColor: COLOR_MGREY, backgroundColor: COLOR_LGREY, alignItems: 'flex-start', justifyContent: 'center', overflow: 'hidden' },
	cardTitleText: { flex:1, flexWrap: 'wrap', width: MAX_CARD_WIDTH, padding: 8, borderBottomWidth: 1, borderBottomColor: COLOR_MGREY, fontSize: 17, color: COLOR_BLACK },
	cardInfoContainer: { flex: 1, flexDirection: 'row', padding: 14, borderBottomWidth: 1, borderBottomColor: COLOR_MGREY, alignItems: 'center' },
	descContainer: { flex: 1 },
	descText: { flexWrap: 'wrap', fontSize: 14, color: COLOR_DGREY, paddingTop: 8 },
	touchableRow: { paddingHorizontal: 0, paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: COLOR_MGREY, },
	titleText: { fontSize: 17, color: COLOR_BLACK, alignSelf: 'stretch' },
	listInfoContainer: { flexDirection: 'row', paddingVertical: 8 },
	dateText: { fontSize: 11, color: COLOR_PRIMARY, paddingTop: 8 },
	image: { width: 120, height: 70, marginLeft: 10, borderWidth: 1, borderColor: COLOR_MGREY },
});

export default DataItem;
