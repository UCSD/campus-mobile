import { getTimestampNumeric } from '../util/general';
import { getClasses } from '../views/schedule/scheduleData';

const AppSettings = require('../AppSettings');
const dateFormat = require('dateformat');

const ScheduleService = {

	FetchSchedule() {
        return getClasses();
    }
};

export default ScheduleService;
