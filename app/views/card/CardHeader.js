'use strict'
import React from 'react'
import {
	View,
	Text,
	Image,
	ActivityIndicator,
	TouchableHighlight,
} from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';

var css = require('../../styles/css');

export default class CardHeader extends React.Component {
	render() {
		let refresh;
		if (this.props.cardRefresh) {
			refresh = this.props.isRefreshing ?
				<ActivityIndicator animating={true} />
				:
				<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={this.props.cardRefresh}>
					<Image style={css.shuttle_card_refresh} source={require('../../assets/img/icon_refresh_grey.png')} />
				</TouchableHighlight>
		}
		return (
			<View style={css.card_title_container}>
				<Text style={css.card_title}>{this.props.title}</Text>
				<View style={css.shuttle_card_refresh_container}>
					{refresh}
				</View>
			</View>
		);
	}
}
//{refresh} <Icon name="caret-down" size={20} color={"#747678"}/>