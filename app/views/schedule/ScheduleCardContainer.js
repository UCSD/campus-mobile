import React from 'react';
import { Actions } from 'react-native-router-flux';
import { connect } from 'react-redux';

import FullScheduleButton from './FullScheduleButton';
import ScheduleCard from './ScheduleCard';
import { getClasses } from './scheduleData'
import logger from '../../util/logger';

/**
 * Container component for [ScheduleCard]{@link ScheduleCard}
**/

const mockData = (scheduleData) => {
	let result = [];
	result.push(...scheduleData.MO);
	result.push(...scheduleData.TU);
	result.push(...scheduleData.WE);
	result.push(...scheduleData.TH);
	result.push(...scheduleData.FR);
	result = result.slice(0, 4);
	// console.log(result);
	return result;
};

const mockDisplay = {
	leftHalf_upper_timeText_firstSection: "Today 9",
	leftHalf_upper_timeText_secondSection: "AM",
	leftHalf_upper_classText_firstSection: "CSE 198",
	leftHalf_upper_classText_secondSection: "Lecture",
	leftHalf_lower_sections_text1_topSection: "In Session",
	leftHalf_lower_sections_text1_bottomSection: "9:00 AM to 9:50 AM",
	leftHalf_lower_sections_text2_topSection: "Pepper Canyon Hall 106",
	leftHalf_lower_sections_text2_bottomSection: "In Sixth College",
	leftHalf_lower_sections_text3_topSection: "1 More Class Today",
	leftHalf_lower_sections_text3_bottomSection: "Last Class Ends at 10:00 AM",
};

class ScheduleCardContainer extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			upcoming4Courses : mockDisplay,
			activeCourse : 0,
		};
		this.onClickCourse = this.onClickCourse.bind(this);
	}
	onClickCourse(newActiveCourse) {
		this.setState((prevState) => ({
			...prevState,
			activeCourse : newActiveCourse
		}));
	}
	componentWillMount() {
		logger.ga('Card Mounted: Schedule');
	}
	render() {
		return (
			<ScheduleCard
				mainDisplay={mockDisplay}
				onClickCourse = {this.onClickCourse}
				upcoming4Courses={mockData(this.props.scheduleData)}
				activeCourse={this.state.activeCourse}
				actionButton={<FullScheduleButton />}
			/>
		);
	}
};

const mapStateToProps = (state) => (
	{
		scheduleData: state.schedule.data,
	}
);

const ActualScheduleCard = connect(
	mapStateToProps
)(ScheduleCardContainer);

export default ActualScheduleCard;
