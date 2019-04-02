import 'react-native'
import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

// Component to be tested
import { WeatherCardContainer } from '../../../app/views/weather/WeatherCardContainer'
import WeatherCard from '../../../app/views/weather/WeatherCard'
import SurfButton from '../../../app/views/weather/SurfButton'
import { WEATHER_RESPONSE } from '../../../mockApis/weatherApi'

Enzyme.configure({ adapter: new Adapter() })

// Mock props passed down from state
const initialState = {
	weatherData: WEATHER_RESPONSE,
	actionButton: (<SurfButton />)
}

// Set up container to be rendered
function setupContainer(props) {
	return shallow(<WeatherCardContainer {...props} />)
}

test('container renders without crashing', () => {
	const tree = setupContainer(initialState)
	expect(tree).toMatchSnapshot()
})

// Set up card to be rendered
function setupCard(props) {
	return shallow(<WeatherCard {...props} />)
}

test('card renders without crashing', () => {
	const tree = setupCard(initialState)
	expect(tree).toMatchSnapshot()
})
