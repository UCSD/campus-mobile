import React from 'react';
import {
	View,
	Text,
	StyleSheet,
} from 'react-native';

export default class CardHeader extends React.Component {
	render() {
		return (
			<View style={styles.container}>
				<Text style={styles.title}>{this.props.title}</Text>
				{this.props.menu}
			</View>
		);
	}
}

const styles = StyleSheet.create({
	container: {
		flexDirection: 'row',
		alignItems: 'center',
		borderBottomWidth: 1,
		borderBottomColor: '#DDD',
		alignSelf: 'stretch',
	},
	title: {
		fontSize: 26,
		margin: 8,
		color: '#747678'
	},
});