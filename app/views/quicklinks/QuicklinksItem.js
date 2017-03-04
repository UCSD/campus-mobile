import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	Image,
} from 'react-native';

import Icon from 'react-native-vector-icons/FontAwesome';

const css = require('../../styles/css');
const general = require('../../util/general');

var ListStyle = function(listType) {
	if (listType === 'full') {
		return css.links_row_full;
	} else {
		return null;
	}
}

const QuicklinksItem = ({ data, listType }) => (
	<View style={css.quicklinks_row_container}>
		{(data.name && data.url && data.icon) ? (
			<TouchableHighlight underlayColor="rgba(100,100,100,.1)" onPress={() => general.openURL(data.url)}>
				<View style={[css.quicklinks_row, ListStyle(listType)]}>
					{data.icon.indexOf('fontawesome:') === 0 ? (
						<Icon name={data.icon.replace('fontawesome:','')} size={26} color={'#014365'} style={css.quicklinks_icon_fa} />
					) : (
						<Image style={css.quicklinks_icon} source={{ uri: data.icon }} />
					)}
					<Text style={css.quicklinks_name}>{data.name}</Text>
					<Icon name={'angle-right'} size={18} color={'rgba(100,100,100,.5)'} />
				</View>
			</TouchableHighlight>
		) : (null)}
	</View>
);

export default QuicklinksItem;
