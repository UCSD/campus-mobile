import React, { Component } from 'react';
import {
	View,
	StyleSheet,
	Text,
} from 'react-native';

import logger from '../../util/logger';
import SpecialEventsListView from './SpecialEventsListView';
import {
	COLOR_PRIMARY,
	COLOR_LGREY,
	COLOR_DGREY,
	COLOR_WHITE,
	COLOR_MGREY,
} from '../../styles/ColorConstants';
import {
	TAB_BAR_HEIGHT,
	NAVIGATOR_HEIGHT,
} from '../../styles/LayoutConstants';
import Touchable from '../common/Touchable';


export default class SpecialEventsView extends Component {
	constructor(props) {
		super(props);

		this.state = {
			personal: false
		};
	}

	componentDidMount() {
		logger.ga('View Loaded: SpecialEventsView');
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
				style={[styles.main_container, styles.greybg]}
			>
				<SpecialEventsListView
					style={styles.specialEventsListView}
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
	<View style={styles.tabBar}>
		<View
			style={styles.buttonContainer}
		>
			<Touchable
				style={personal ? styles.plainButton : styles.selectedButton}
				onPress={() => handleFullPress()}
			>
				<Text
					style={personal ? styles.plainText : styles.selectedText}
				>
					Full Schedule
				</Text>
			</Touchable>
			<Touchable
				style={personal ? styles.selectedButton : styles.plainButton}
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
	main_container: { flex: 1, backgroundColor: COLOR_MGREY, marginTop: NAVIGATOR_HEIGHT },
	specialEventsListView: { flex: 1 },
	greybg: { backgroundColor: COLOR_LGREY },
	buttonContainer: { flex: 1, flexDirection: 'row', alignItems: 'center' },
	selectedButton: { flex: 1, height: TAB_BAR_HEIGHT, alignItems: 'center', justifyContent: 'center', backgroundColor: COLOR_PRIMARY },
	plainButton: { flex: 1, height: TAB_BAR_HEIGHT, alignItems: 'center', justifyContent: 'center', backgroundColor: COLOR_WHITE },
	selectedText: { textAlign: 'center', fontSize: 18, color: 'white' },
	plainText: { textAlign: 'center', fontSize: 18, opacity: 0.5 },
	tabBar: { borderTopWidth: 1, borderColor: COLOR_DGREY, backgroundColor: COLOR_WHITE, height: TAB_BAR_HEIGHT },
});
