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

export default class QuicklinksItem extends React.Component {

	render() {
		const data = this.props.data;
		
		if (data.name && data.url && data.icon) {
			return (
				<TouchableHighlight underlayColor="rgba(100,100,100,.1)" onPress={ () => general.openURL(data.url) }>
					<View style={css.quicklinks_row}>
						<Image style={css.quicklinks_icon} source={{ uri: data.icon }} />
						<Text style={css.quicklinks_name}>{data.name}</Text>
						<Icon name={'angle-right'} size={18} color={'rgba(100,100,100,.5)'} />
					</View>
				</TouchableHighlight>
			);
		} else {
			return null;
		}
	}
}