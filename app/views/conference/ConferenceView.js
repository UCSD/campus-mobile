import React, { Component } from 'react';
import {
	View,
	StyleSheet,
	Platform,
	Text,
} from 'react-native';
import logger from '../../util/logger';
import css from '../../styles/css';
import ConferenceListView from './ConferenceListView';
import { platformIOS } from '../../util/general';
import {
	COLOR_PRIMARY,
	COLOR_MGREY,
	COLOR_LGREY,
	COLOR_WHITE,
} from '../../styles/ColorConstants';
import { TAB_BAR_HEIGHT } from '../../styles/LayoutConstants';
import Touchable from '../common/Touchable';


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
					style={styles.conferenceListView}
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
	<View style={ platformIOS ? styles.tabBarIOS : styles.tabBarAndroid }>
		<View
			style={styles.buttonContainer}
		>
			<Touchable
				style={[styles.button, { backgroundColor: personal ? COLOR_WHITE : COLOR_PRIMARY }]}
				onPress={() => handleFullPress()}
			>
				<Text
					style={personal ? styles.plainText : styles.selectedText}
				>
					Full Schedule
				</Text>
			</Touchable>
			<Touchable
				style={[styles.button, { backgroundColor: personal ? COLOR_PRIMARY : COLOR_WHITE }]}
				onPress={() => handleMinePress()}
			>
				<Text
					style={personal ? styles.selectedText : styles.plainText}
				>
					My Schedule
				</Text>
			</Touchable>
		</View>
	</View>
);

const styles = StyleSheet.create({
	conferenceListView: { marginBottom: TAB_BAR_HEIGHT, flexGrow: 1 },
	greybg: { backgroundColor: COLOR_LGREY },
	buttonContainer: { flex: 1, flexDirection: 'row' },
	button: { flex: 1, alignItems: 'center', justifyContent: 'center' },
	buttonSelected: { backgroundColor: COLOR_PRIMARY },
	selectedText: { fontSize: 18, color: COLOR_WHITE },
	plainText: { fontSize: 18, opacity: 0.5 },
	tabBarIOS: { marginTop: -TAB_BAR_HEIGHT, borderTopWidth: 1, borderColor: '#DADADA', backgroundColor: COLOR_WHITE, height: TAB_BAR_HEIGHT },
	tabBarAndroid: { borderBottomWidth: 1, borderColor: '#DADADA', backgroundColor: COLOR_WHITE, height: TAB_BAR_HEIGHT },
});
