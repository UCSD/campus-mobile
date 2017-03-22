import React, { PropTypes } from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	StyleSheet
} from 'react-native';

import SafeImage from './SafeImage';
import {
	getCampusPrimary,
	getMaxCardWidth
} from '../../util/general';

/**
 * Generic row item
 * @param  {Object} data
 * @param {Boolean} card Display using card style
 * @param {Function} onPress
 * @return {JSX}
 * @todo  Standardize and make this more generic/applicable?
 */
const DataItem = ({ data, card, onPress }) => (
	<View>
		{
			(card) ?
			(
				<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => onPress(data)}>
					<View style={styles.card_main}>
						<View style={styles.events_card_title_container}>
							<Text style={styles.events_card_title}>{data.title}</Text>
						</View>
						<View style={styles.events_card_container}>
							<View style={styles.events_card_left_container}>
								{data.description ? (<Text style={styles.events_card_desc} numberOfLines={3}>{data.description}</Text>) : null }
								<Text style={styles.events_card_postdate}>{data.subtext}</Text>
							</View>
							<SafeImage style={styles.events_card_image} source={{ uri: data.image }} />
						</View>
					</View>
				</TouchableHighlight>
			) :
			(
				<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => onPress(data)}>
					<View style={styles.events_list_row}>
						<Text
							style={styles.events_list_title}
							numberOfLines={1}
						>
							{data.title}
						</Text>

						<View style={styles.events_list_info}>
							<View style={styles.events_list_info_left}>
								{data.description ? (
									<Text
										style={styles.events_list_desc}
										numberOfLines={3}
									>
										{data.description.trim()}
										}
									</Text>
								) : null }
								<Text style={styles.events_list_postdate}>{data.subtext}</Text>
							</View>

							<SafeImage style={styles.events_list_image} source={{ uri: data.image }} />
						</View>
					</View>
				</TouchableHighlight>
			)
		}
	</View>
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
	card_main: { borderWidth: 1, borderRadius: 2, borderColor: '#DDD', backgroundColor: '#F9F9F9', margin: 6, alignItems: 'flex-start', justifyContent: 'center', overflow: 'hidden' },
	events_card_title_container: { flexDirection: 'row', alignItems: 'center', width: getMaxCardWidth(), padding: 8, borderBottomWidth: 1, borderBottomColor: '#DDD' },
	events_card_title: { flex:1, flexWrap: 'wrap', fontSize: 17, color: '#000' },
	events_card_container: { flexDirection: 'row', padding: 14, borderBottomWidth: 1, borderBottomColor: '#EEE', alignItems: 'center' },
	events_card_left_container: { flex: 10 },
	events_card_desc: { flexWrap: 'wrap', fontSize: 14, color: '#666', paddingTop: 8 },
	events_card_postdate: { fontSize: 11, color: getCampusPrimary(), paddingTop: 8 },
	events_card_image: { width: 130, height: 73, marginRight: 4, marginLeft: 10, borderWidth: 1, borderColor: '#CCC' },

	events_list_row: { paddingHorizontal: 0, paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: '#EEE', },
	events_list_title: { fontSize: 17, color: '#000', alignSelf: 'stretch' },
	events_list_info: { flexDirection: 'row', paddingVertical: 8 },
	events_list_info_left: { flex: 1 },
	events_list_postdate: { fontSize: 11, color: getCampusPrimary(), paddingTop: 8 },
	events_list_image: { width: 120, height: 70, marginLeft: 10, borderWidth: 1, borderColor: '#EEE' },
});

export default DataItem;
