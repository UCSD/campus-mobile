import 'react-native'
import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

// Component to be tested
import { ShuttleCardContainer } from '../../../app/views/shuttle/ShuttleCardContainer'
import { ShuttleCard } from '../../../app/views/shuttle/ShuttleCard'
import {
	CLOSEST_STOP,
	SHUTTLE_STOPS_DATA,
	SHUTTLE_STOPS,
	SHUTTLE_ROUTES
} from '../../../mockApis/shuttleApi'

Enzyme.configure({ adapter: new Adapter() })

// Mock props passed down from state
const initialContainerState = {
	closestStop: CLOSEST_STOP,
	stopsData: SHUTTLE_STOPS_DATA,
	shuttle_routes: SHUTTLE_ROUTES,
	shuttle_stops: SHUTTLE_STOPS,
	savedStops: [],
	lastScroll: 0
}

const initialCardState = {
	savedStops: [],
	stopsData: SHUTTLE_STOPS_DATA,
	gotoSavedList: jest.fn(),
	gotoRoutesList: jest.fn(),
	removeStop: jest.fn(),
	updateScroll: jest.fn(),
	lastScroll: 0,
	navigation: {
		navigate: jest.fn()
	}
}

// Set up container to be rendered
// Set up card to be rendered
function setupContainer(props) {
	return shallow(<ShuttleCardContainer {...props} />)
}

test('container renders without crashing', () => {
	const tree = setupContainer(initialContainerState)
	expect(tree).toMatchSnapshot()
})

// Set up card to be rendered
function setupCard(props) {
	return shallow(<ShuttleCard {...props} />)
}

test('card renders without crashing', () => {
	const tree = setupCard(initialCardState)
	expect(tree).toMatchSnapshot()
})
