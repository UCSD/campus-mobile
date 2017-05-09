import React, { Component } from 'react';
import {
	View,
	StyleSheet,
	Platform,
	TouchableOpacity,
	Text
} from 'react-native';

import logger from '../../util/logger';
import css from '../../styles/css';
import ConferenceListView from './ConferenceListView';


export default class ConferenceView extends Component {

	constructor(props) {
		super(props);

		this.state = {
			personal: false
		};
	}

	componentDidMount() {
		logger.ga('View Loaded: ConferenceView');
	}

	handleFullPress = () => {
		this.setState({ personal: false });
	}

	handleMinePress = () => {
		this.setState({ personal: true });
	}

	render() {
		return (
			<View
				style={[css.main_container, styles.greybg]}
			>
				<ConferenceListView
					scrollEnabled={true}
					personal={this.state.personal}
				/>
				<FakeTabBar
					personal={this.state.personal}
					handleFullPress={this.handleFullPress}
					handleMinePress={this.handleMinePress}
				/>
			</View>
		);
	}
}

const FakeTabBar = ({ personal, handleFullPress, handleMinePress }) => (
	<View
		style={
			Platform.select({
				ios: styles.tabBarIOS,
				android: styles.tabBarAndroid
			})
		}
	>
		<View
			style={styles.buttonContainer}
		>
			<TouchableOpacity
				style={styles.button}
				onPress={() => handleFullPress()}
			>
				<Text
					style={personal ? styles.plainText : styles.selectedText}
				>
					Full
				</Text>
			</TouchableOpacity>
			<TouchableOpacity
				style={styles.button}
				onPress={() => handleMinePress()}
			>
				<Text
					style={personal ? styles.selectedText : styles.plainText}
				>
					Mine
				</Text>
			</TouchableOpacity>
		</View>
	</View>
);

const NavigatorAndroidHeight = 44;
const TabBarHeight = 40;

const styles = StyleSheet.create({
	greybg: { backgroundColor: '#F9F9F9' },
	buttonContainer: { flex: 1, flexDirection: 'row' },
	button: { flex: 1, alignItems: 'center', justifyContent: 'center' },
	selectedText: { fontSize: 18 },
	plainText: { fontSize: 18, opacity: 0.5 },
	tabBarIOS: { borderTopWidth: 1, borderColor: '#DADADA', backgroundColor: '#FFF', height: TabBarHeight },
	tabBarAndroid: { top: NavigatorAndroidHeight, borderBottomWidth: 1, borderColor: '#DADADA', backgroundColor: '#FFF', height: TabBarHeight },
});
