import 'react-native'
import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

// Component to be tested
import { Home } from '../../../app/views/home/Home'

Enzyme.configure({ adapter: new Adapter() })

// Mock props passed down from state
const initialState = {
	scene: {
		sceneKey: 'Home'
	},
	cards: {
		specialEvents: {
			id: 'specialEvents', active: false, autoActivated: false, name: 'Special Events', component: 'SpecialEventsCard'
		},
		weather: {
			id: 'weather', active: true, name: 'Weather', component: 'WeatherCard'
		},
		shuttle: {
			id: 'shuttle', active: true, name: 'Shuttle', component: 'ShuttleCard'
		},
		dining: {
			id: 'dining', active: true, name: 'Dining', component: 'DiningCard'
		},
		events: {
			id: 'events', active: true, name: 'Events', component: 'EventsCard'
		},
		quicklinks: {
			id: 'quicklinks', active: true, name: 'Links', component: 'QuicklinksCard'
		},
		news: {
			id: 'news', active: true, name: 'News', component: 'NewsCard'
		},
	},
	cardOrder: ['specialEvents', 'weather', 'shuttle', 'dining', 'events', 'quicklinks', 'news']
}

// Set up component to be rendered
function setup(props) {
	return shallow(<Home {...props} />)
}

test('renders without crashing', () => {
	const tree = setup(initialState)
	expect(tree).toMatchSnapshot()
})
