import cardsReducer from './cards'
import locationReducer from './location'
import shuttleReducer from './shuttle'
import mapReducer from './map'
import userReducer from './user'
import weatherReducer from './weather'
import surfReducer from './surf'
import diningReducer from './dining'
import eventsReducer from './events'
import newsReducer from './news'
import linksReducer from './links'
import routesReducer from './routes'
import scheduleReducer from './schedule'
import specialEventsReducer from './specialEvents'
import feedbackReducer from './feedback'
import requestStatusesReducer from './requestStatuses'
import requestErrorsReducer from './requestErrors'
import homeReducer from './home'
import parkingReducer from './parking'
import messagesReducer from './messages'
import studentProfileReducer from './studentProfile'
import supplementalInstructionReducer from './supplementalInstruction'
import occuspaceReducer from './occuspace'

const rootReducer = {
	cards: cardsReducer,
	location: locationReducer,
	shuttle: shuttleReducer,
	map: mapReducer,
	user: userReducer,
	weather: weatherReducer,
	surf: surfReducer,
	dining: diningReducer,
	events: eventsReducer,
	news: newsReducer,
	links: linksReducer,
	routes: routesReducer,
	specialEvents: specialEventsReducer,
	schedule: scheduleReducer,
	feedback: feedbackReducer,
	requestStatuses: requestStatusesReducer,
	requestErrors: requestErrorsReducer,
	home: homeReducer,
	parking: parkingReducer,
	messages: messagesReducer,
	supplementalInstruction: supplementalInstructionReducer,
	occuspace: occuspaceReducer,
	studentProfile: studentProfileReducer,
}

export default rootReducer
