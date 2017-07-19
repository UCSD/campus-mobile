import React, { Component } from 'react';
import {
	View,
	StyleSheet,
	Text,
	ScrollView,
} from 'react-native';
import { connect } from 'react-redux';
import { Actions } from 'react-native-router-flux';
import moment from 'moment';

import css from '../../styles/css';
import general from '../../util/general';
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
	WINDOW_WIDTH,
} from '../../styles/LayoutConstants';
import Touchable from '../common/Touchable';
import MultiSelect from './MultiSelect';

class SpecialEventsView extends Component {
	constructor(props) {
		super(props);

		// Calculate selected day
		let selectedDay;

		for (let i = 0; i < props.days.length; ++i) {
			selectedDay = i;
			if (moment(props.days[i]).isSameOrAfter(moment(), 'day')) {
				break;
			}
		}

		this.state = {
			personal: this.props.personal,
			onFilter: false,
			selectedDay,
		};
	}

	componentDidMount() {
		logger.ga('View Loaded: SpecialEventsView');

		Actions.refresh({
			backButton: this.renderBackButton(this.state.onFilter),
			filterButton: this.renderFilterButton()
		});
	}


	handleFullPress = () => {
		Actions.refresh({
			filterButton: this.renderFilterButton(this.state.onFilter)
		});
		this.setState({ personal: false });
	}

	handleMinePress = () => {
		Actions.refresh({
			filterButton: null
		});
		this.setState({ personal: true });
	}

	handleFilterPress = () => {
		Actions.refresh({
			backButton: this.renderBackButton(!this.state.onFilter),
			filterButton: this.renderFilterButton(!this.state.onFilter)
		});
		this.setState({ onFilter: !this.state.onFilter });
	}

	handleFilterSelect = (labels) => {
		this.props.updateSpecialEventsLabels(labels);
	}

	handleDayPress = (index) => {
		this.setState({ selectedDay: index });
	}

	renderFilterButton = (onFilter) => {
		if (!onFilter) {
			return (
				<Touchable
					onPress={this.handleFilterPress}
				>
					<Text
						style={general.platformIOS() ? css.navButtonTextIOS : css.navButtonTextAndroid}
					>
						Filter
						</Text>
				</Touchable>
			);
		} else {
			return null;
		}
	}

	renderBackButton = (onFilter) => {
		return (
			<Touchable
				onPress={() => (onFilter) ? (this.handleFilterPress()) : (Actions.pop())}
			>
				<Text
					style={general.platformIOS() ? css.navButtonTextIOS : css.navButtonTextAndroid}
				>
					Back
				</Text>
			</Touchable>
		);
	}

	render() {
		if (this.state.onFilter) {
			return (
				<View
					style={[styles.main_container, styles.greybg]}
				>
					<MultiSelect
						items={this.props.specialEventsLabels}
						themes={this.props.specialEventsLabelThemes}
						selected={this.props.labels}
						onSelect={this.handleFilterSelect}
					/>
				</View>
			);
		} else {
			return (
				<View
					style={[styles.main_container, styles.greybg]}
				>
					<DaysBar
						days={this.props.days}
						selectedDay={this.state.selectedDay}
						handleDayPress={this.handleDayPress}
					/>
					<SpecialEventsListView
						style={styles.specialEventsListView}
						scrollEnabled={true}
						personal={this.state.personal}
						selectedDay={this.props.days[this.state.selectedDay]}
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
}

const mapStateToProps = (state) => (
	{
		specialEventsLabels: state.specialEvents.data.labels,
		specialEventsLabelThemes: state.specialEvents.data['label-themes'],
		labels: state.specialEvents.labels,
		days: state.specialEvents.data.dates,
	}
);

const mapDispatchToProps = (dispatch) => (
	{
		updateSpecialEventsLabels: (labels) => {
			dispatch({ type: 'UPDATE_SPECIAL_EVENTS_LABELS', labels });
		},
	}
);

export default connect(mapStateToProps, mapDispatchToProps)(SpecialEventsView);

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

const DaysBar = ({ days, selectedDay, handleDayPress }) => {
	return (
		<View style={styles.daysBar}>
			<ScrollView
				horizontal
				showsHorizontalScrollIndicator={false}
				style={styles.scrollButtonContainer}
				contentContainerStyle={styles.scrollContentContainer}
			>
				{
					days.map((day, index) =>
						<Touchable
							key={day}
							style={styles.plainButton}
							onPress={() => handleDayPress(index)}
						>
							<Text
								style={index !== selectedDay ? styles.plainText : styles.selectedDayText}
							>
								Day {index + 1}
							</Text>
						</Touchable>
					)
				}
			</ScrollView>
		</View>
	);
};

const styles = StyleSheet.create({
	main_container: { flex: 1, backgroundColor: COLOR_MGREY, marginTop: NAVIGATOR_HEIGHT },
	specialEventsListView: { flex: 1 },
	greybg: { backgroundColor: COLOR_LGREY },
	scrollButtonContainer: { flexDirection: 'row' },
	scrollContentContainer: { flexGrow: 1 },
	buttonContainer: { flex: 1, flexDirection: 'row', alignItems: 'center' },
	selectedButton: { flexGrow: 1, minWidth: WINDOW_WIDTH / 4, height: TAB_BAR_HEIGHT, alignItems: 'center', justifyContent: 'center', backgroundColor: COLOR_PRIMARY },
	plainButton: { flexGrow: 1, minWidth: WINDOW_WIDTH / 4, height: TAB_BAR_HEIGHT, alignItems: 'center', justifyContent: 'center', backgroundColor: COLOR_WHITE },
	selectedText: { textAlign: 'center', fontSize: 18, color: 'white' },
	plainText: { textAlign: 'center', fontSize: 18, opacity: 0.5 },
	tabBar: { borderTopWidth: 1, borderColor: COLOR_DGREY, backgroundColor: COLOR_WHITE, height: TAB_BAR_HEIGHT },

	daysBar: { borderBottomWidth: 1, borderColor: COLOR_DGREY, backgroundColor: COLOR_WHITE, height: TAB_BAR_HEIGHT },
	selectedDayText: { textAlign: 'center', fontSize: 18, color: COLOR_PRIMARY },

	filterText: { textAlign: 'center', fontSize: 17, color: 'white' },
});
