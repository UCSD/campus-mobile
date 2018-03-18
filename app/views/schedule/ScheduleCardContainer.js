import React from 'react';
import { connect } from 'react-redux';
// import { Actions } from 'react-native-router-flux';

import FullScheduleButton from './FullScheduleButton';
import ScheduleCard from './ScheduleCard';
import logger from '../../util/logger';

/**
 * Container component for [ScheduleCard]{@link ScheduleCard}
 * */

const processData = (scheduleData) => {
	if (!scheduleData) return [];
	let result = [];
	result.push(...scheduleData.MO);
	result.push(...scheduleData.TU);
	result.push(...scheduleData.WE);
	result.push(...scheduleData.TH);
	result.push(...scheduleData.FR);
	result = result.slice(0, 4);
	return result;
};

class ScheduleCardContainer extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			upcoming4Courses: processData(props.scheduleData),
			activeCourse: 0
		};
		this.onClickCourse = this.onClickCourse.bind(this);
	}

	componentWillMount() {
		logger.ga('Card Mounted: Schedule');
	}
	componentWillReceiveProps(nextProps) {
		if (nextProps.scheduleData) {
			// console.warn('receive new prop');
			this.setState((state, props) => ({
				...state,
				upcoming4Courses: processData(props.scheduleData)
			}));
		}
	}
	onClickCourse(newActiveCourse) {
		this.setState(prevState => ({
			...prevState,
			activeCourse: newActiveCourse,
		}));
		this.forceUpdate();
	}
	render() {
		return (
			<ScheduleCard
				onClickCourse={this.onClickCourse}
				// waitingData={this.state.courseDataReceived}
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
