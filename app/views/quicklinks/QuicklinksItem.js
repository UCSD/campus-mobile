import React from 'react';
import {
	View,
	Text,
	Image,
	StyleSheet
} from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';

import {
	COLOR_LGREY,
	COLOR_MGREY,
	COLOR_DGREY,
	COLOR_PRIMARY,
	COLOR_BLACK
} from '../../styles/ColorConstants';
import Touchable from '../common/Touchable';
import { openURL } from '../../util/general';

const QuicklinksItem = ({ data }) => (
	<View style={styles.quicklinks_row_container}>
		{(data.name && data.url && data.icon) ? (
			<Touchable onPress={() => openURL(data.url)}>
				<View style={styles.quicklinks_row}>
					{data.icon.indexOf('fontawesome:') === 0 ? (
						<Icon
							name={data.icon.replace('fontawesome:','')}
							size={26}
							style={styles.quicklinks_icon_fa}
						/>
					) : (
						<Image style={styles.quicklinks_icon} source={{ uri: data.icon }} />
					)}
					<Text style={styles.quicklinks_name}>{data.name}</Text>
					<Icon
						name={'chevron-right'}
						size={20}
						style={styles.arrowIcon}
					/>
				</View>
			</Touchable>
		) : (null)}
	</View>
);

const styles = StyleSheet.create({
	links_row_full: { paddingHorizontal: 12 },
	quicklinks_row_container: { borderBottomWidth: 1, backgroundColor: COLOR_LGREY, borderBottomColor: COLOR_MGREY, paddingVertical: 10 },
	quicklinks_row: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center' },
	quicklinks_icon: { height: 42, width: 38 },
	quicklinks_icon_fa: { padding: 8, color: COLOR_PRIMARY },
	quicklinks_name: { flexGrow: 5, color: COLOR_BLACK, fontSize: 16, paddingHorizontal: 8 },
	arrowIcon: { color: COLOR_DGREY },
});

export default QuicklinksItem;
