import React from 'react';
import { connect } from 'react-redux';
import { Actions } from 'react-native-router-flux';

import FullScheduleButton from './FullScheduleButton';
import ScheduleCard from './ScheduleCard';
import logger from '../../util/logger';

/**
 * Container component for [ScheduleCard]{@link ScheduleCard}
 * */

const processData = (scheduleData) => {
	let result = [];
	result.push(...scheduleData.MO);
	result.push(...scheduleData.TU);
	result.push(...scheduleData.WE);
	result.push(...scheduleData.TH);
	result.push(...scheduleData.FR);
	result = result.slice(0, 4);
	return result;
};

const mockDisplay = {
	leftHalf_upper_timeText_firstSection: 'Today 9',
	leftHalf_upper_timeText_secondSection: 'AM',
	leftHalf_upper_classText_firstSection: 'CSE 198',
	leftHalf_upper_classText_secondSection: 'Lecture',
	leftHalf_lower_sections_text1_topSection: 'In Session',
	leftHalf_lower_sections_text1_bottomSection: '9:00 AM to 9:50 AM',
	leftHalf_lower_sections_text2_topSection: 'Pepper Canyon Hall 106',
	leftHalf_lower_sections_text2_bottomSection: 'In Sixth College',
	leftHalf_lower_sections_text3_topSection: '1 More Class Today',
	leftHalf_lower_sections_text3_bottomSection: 'Last Class Ends at 10:00 AM'
};

class ScheduleCardContainer extends React.Component {
	constructor(props) {
		super(props);
		// console.warn(JSON.stringify(this.props));
		this.state = {
			mainDisplay: mockDisplay,
			upcoming4Courses: processData(props.scheduleData),
			activeCourse: 0
		};
		this.onClickCourse = this.onClickCourse.bind(this);
	}

	componentWillMount() {
		logger.ga('Card Mounted: Schedule');
	}
	onClickCourse(newActiveCourse) {
		this.setState(prevState => ({
			...prevState,
			activeCourse: newActiveCourse,
			mainDisplay: {
				leftHalf_upper_classText_firstSection: this.props.scheduleData
			}
		}));
	}
	render() {
		return (
			<ScheduleCard
				onClickCourse={this.onClickCourse}
				mainDisplay={this.state.mainDisplay}
				coursesToShow={this.state.upcoming4Courses}
				activeCourse={this.state.activeCourse}
				actionButton={<FullScheduleButton />}
			/>
		);
	}
}

const mapStateToProps = state => ({
	scheduleData: state.schedule.data
});

export default connect(mapStateToProps)(ScheduleCardContainer);
