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
export const ScheduleCardContainer = ({ scheduleData }) => {
    logger.ga('Card Mounted: Schedule');
    // console.log(scheduleData);
    // scheduleData = getClasses();

	return (
        <ScheduleCard
            scheduleData={scheduleData}
            actionButton={<FullScheduleButton />}
        />
	);
};

const mapStateToProps = (state) => (
	{
		scheduleData: getClasses(),
	}
);

const ActualScheduleCard = connect(
	mapStateToProps
)(ScheduleCardContainer);

export default ActualScheduleCard;
