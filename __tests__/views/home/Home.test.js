import 'react-native'
import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

// Component to be tested
import { Home } from '../../../app/views/home/Home'

Enzyme.configure({ adapter: new Adapter() })

// Mock props passed down from state
const initialState = {
	cards: {
		specialEvents: {
			id: 'specialEvents',
			active: false,
			autoActivated: false,
			name: 'Special Events',
			component: 'SpecialEventsCard'
		},
		finals: {
			id: 'finals',
			active: true,
			name: 'Finals',
			component: 'FinalsCard',
			authenticated: true,
			autoActivated: false,
			classifications: { student: true }
		},
		schedule: {
			id: 'schedule',
			active: true,
			name: 'Classes',
			component: 'ScheduleCard',
			authenticated: true,
			classifications: { student: true }
		},
		shuttle: {
			id: 'shuttle',
			active: true,
			name: 'Shuttle',
			component: 'ShuttleCard'
		},
		dining: {
			id: 'dining',
			active: true,
			name: 'Dining',
			component: 'DiningCard'
		},
		events: {
			id: 'events',
			active: true,
			name: 'Events',
			component: 'EventsCard'
		},
		news: {
			id: 'news',
			active: true,
			name: 'News',
			component: 'NewsCard',
		},
		quicklinks: {
			id: 'quicklinks',
			active: true,
			name: 'Links',
			component: 'QuicklinksCard'
		},
		weather: {
			id: 'weather',
			active: true,
			name: 'Weather',
			component: 'WeatherCard'
		},
		parking: {
			id: 'parking',
			active: true,
			name: 'Parking',
			component: 'ParkingCard'
		}
	},

	// Only cards that show up by default
	// on first launch should appear here.
	cardOrder: [
		'shuttle',
		'parking',
		'dining',
		'events',
		'news',
		'quicklinks',
		'weather'
	],
}

// Set up component to be rendered
function setup(props) {
	return shallow(<Home {...props} />)
}

test('renders without crashing', () => {
	const tree = setup(initialState)
	expect(tree).toMatchSnapshot()
})
