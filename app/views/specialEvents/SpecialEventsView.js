import React, { Component } from 'react';
import {
	View,
	StyleSheet,
	Text,
	ScrollView,
	BackAndroid,
} from 'react-native';
import { connect } from 'react-redux';
import { Actions } from 'react-native-router-flux';
import moment from 'moment';
import Icon from 'react-native-vector-icons/Ionicons';
import css from '../../styles/css';
import general from '../../util/general';
import logger from '../../util/logger';
import SpecialEventsListView from './SpecialEventsListView';
import {
	COLOR_PRIMARY,
	COLOR_SECONDARY,
	COLOR_LGREY,
	COLOR_MGREY,
	COLOR_DGREY,
	COLOR_WHITE,
} from '../../styles/ColorConstants';
import {
	TAB_BAR_HEIGHT,
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
		BackAndroid.addEventListener('hardwareBackPress', this.handleBackPress);

		Actions.refresh({
			backButton: this.renderBackButton(this.state.onFilter),
			filterButton: this.renderFilterButton(),
			specialEventsTitle: this.props.specialEventsTitle,
		});
	}

	componentWillUnmount() {
		BackAndroid.removeEventListener('hardwareBackPress', this.handleBackPress);
	}

	// Returns true so router-flux back handler is ignored
	handleBackPress = () => {
		if (this.state.onFilter) {
			this.handleFilterPress();
			return true;
		} else {
			return false;
		}
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
				<View style={styles.backButtonContainer}>
					<Icon
						name={'ios-arrow-back'}
						size={33}
						style={styles.backButtonImage}
					/>
					<Text
						style={general.platformIOS() ? css.navButtonTextIOS : css.navButtonTextAndroid}
					>
						Back
					</Text>
				</View>
			</Touchable>
		);
	}

	render() {
		if (this.state.onFilter) {
			return (
				<View
					style={[css.main_full, css.lgreybg]}
				>
					<MultiSelect
						items={this.props.specialEventsLabels}
						themes={this.props.specialEventsLabelThemes}
						selected={this.props.labels}
						onSelect={this.handleFilterSelect}
						applyFilters={this.handleFilterPress}
					/>
				</View>
			);
		} else {
			return (
				<View
					style={[css.main_full, css.lgreybg]}
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
						handleFilterPress={this.handleFilterPress}
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
		specialEventsTitle: (state.specialEvents.data) ? state.specialEvents.data.name : '',
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
							style={index !== selectedDay ? styles.plainButton : styles.selectedButton }
							onPress={() => handleDayPress(index)}
						>
							<Text
								style={index !== selectedDay ? styles.plainText : styles.selectedDayText}
							>
								{moment(day).format('MMM D')}
							</Text>
						</Touchable>
					)
				}
			</ScrollView>
		</View>
	);
};

const styles = StyleSheet.create({
	specialEventsListView: { flex: 1 },
	greybg: { backgroundColor: COLOR_LGREY },
	scrollButtonContainer: { flexDirection: 'row' },
	scrollContentContainer: { flexGrow: 1 },
	buttonContainer: { flex: 1, flexDirection: 'row', alignItems: 'center' },
	selectedButton: { flexGrow: 1, minWidth: WINDOW_WIDTH / 4, height: TAB_BAR_HEIGHT, alignItems: 'center', justifyContent: 'center', backgroundColor: COLOR_PRIMARY },
	plainButton: { flexGrow: 1, minWidth: WINDOW_WIDTH / 4, height: TAB_BAR_HEIGHT, alignItems: 'center', justifyContent: 'center', backgroundColor: COLOR_WHITE, borderRightWidth: 1, borderRightColor: COLOR_MGREY },
	selectedButton: { flexGrow: 1, minWidth: WINDOW_WIDTH / 4, height: TAB_BAR_HEIGHT, alignItems: 'center', justifyContent: 'center', backgroundColor: COLOR_SECONDARY, borderRightWidth: 1, borderRightColor: COLOR_MGREY },
	selectedText: { textAlign: 'center', fontSize: 18, color: 'white' },
	plainText: { textAlign: 'center', fontSize: 18, opacity: 0.5 },
	tabBar: { borderTopWidth: 1, borderColor: COLOR_DGREY, backgroundColor: COLOR_WHITE, height: TAB_BAR_HEIGHT },
	daysBar: { borderBottomWidth: 1, borderColor: COLOR_MGREY, backgroundColor: COLOR_WHITE, height: TAB_BAR_HEIGHT },
	selectedDayText: { textAlign: 'center', fontSize: 18, color: COLOR_WHITE, backgroundColor: COLOR_SECONDARY },
	filterText: { textAlign: 'center', fontSize: 17, color: 'white' },
	backButtonContainer: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', marginTop: -7 },
	backButtonImage: { color: COLOR_WHITE, marginRight: 7 },
});
