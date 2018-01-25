import 'react-native';
import React from 'react';
import Enzyme, { shallow } from 'enzyme';
import Adapter from 'enzyme-adapter-react-15.4';

// Component to be tested
import { SpecialEventsCard } from '../../../app/views/specialEvents/SpecialEventsCard';
import { SPECIAL_EVENTS_RESPONSE } from '../../../mockApis/specialEventsApi';

Enzyme.configure({ adapter: new Adapter() });

// Mock props passed down from state
const initialState = {
	specialEvents: SPECIAL_EVENTS_RESPONSE,
	saved: [],
	hideCard: jest.fn()
};

// Set up component to be rendered
function setup(props) {
	return shallow(<SpecialEventsCard {...props} />);
}

test('renders without crashing', () => {
	const tree = setup(initialState);
	expect(tree).toMatchSnapshot();
});
