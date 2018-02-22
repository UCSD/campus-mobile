import { getTimestampNumeric } from '../util/general';
import { getClasses } from '../views/schedule/scheduleData';

const AppSettings = require('../AppSettings');
const dateFormat = require('dateformat');

const ScheduleService = {

	FetchSchedule() {
        console.log("TESTING")
        return getClasses().json();
    }
};

export default ScheduleService;
