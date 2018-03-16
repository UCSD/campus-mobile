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
	result = result.slice(0,4);
	// console.log(result);
	return result;
}

export const ScheduleCardContainer = ({ scheduleData }) => {
    logger.ga('Card Mounted: Schedule');
    // console.log(scheduleData);
    // scheduleData = getClasses();

	return (
        <ScheduleCard
            scheduleData={mockData(scheduleData)}
            actionButton={<FullScheduleButton />}
        />
	);
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
