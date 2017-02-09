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

const QuicklinksItem = ({ data }) => (
	<View>
		{(data.name && data.url && data.icon) ? (
			<TouchableHighlight underlayColor="rgba(100,100,100,.1)" onPress={() => general.openURL(data.url)}>
				<View style={css.quicklinks_row}>
					<Image style={css.quicklinks_icon} source={{ uri: data.icon }} />
					<Text style={css.quicklinks_name}>{data.name}</Text>
					<Icon name={'angle-right'} size={18} color={'rgba(100,100,100,.5)'} />
				</View>
			</TouchableHighlight>
		) : (null)}
	</View>
);

export default QuicklinksItem;
