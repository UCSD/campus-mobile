import 'react-native';
import React from 'react';
import Enzyme, { shallow } from 'enzyme';
import Adapter from 'enzyme-adapter-react-15.4';

// Component to be tested
import WeatherCard from '../../../app/views/weather/WeatherCard';
import SurfButton from '../../../app/views/weather/SurfButton';
import { WEATHER_RESPONSE } from '../../../mockApis/weatherApi';

Enzyme.configure({ adapter: new Adapter() });

// Mock props passed down from state
const initialState = {
	weatherData: WEATHER_RESPONSE,
	actionButton: (<SurfButton />)
};

// Set up component to be rendered
function setup(props) {
	return shallow(<WeatherCard {...props} />);
}

test('renders without crashing', () => {
	const tree = setup(initialState);
	expect(tree).toMatchSnapshot();
});
