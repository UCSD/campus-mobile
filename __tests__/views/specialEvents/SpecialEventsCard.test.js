import 'react-native';
import React from 'react';
import Enzyme, { shallow } from 'enzyme';
import Adapter from 'enzyme-adapter-react-15.4';

// Component to be tested
import { SpecialEventsCardContainer } from '../../../app/views/specialEvents/SpecialEventsCardContainer';
import { SpecialEventsCard } from '../../../app/views/specialEvents/SpecialEventsCard';
import { SPECIAL_EVENTS_RESPONSE } from '../../../mockApis/specialEventsApi';

Enzyme.configure({ adapter: new Adapter() });

// Mock props passed down from state
const initialContainerState = {
	specialEventsData: SPECIAL_EVENTS_RESPONSE,
	saved: [],
	hideCard: jest.fn()
};

const initialCardState = {
	specialEvents: SPECIAL_EVENTS_RESPONSE,
	saved: [],
	hideCard: jest.fn()
};

// Set up container to be rendered
// Set up card to be rendered
function setupContainer(props) {
	return shallow(<SpecialEventsCardContainer {...props} />);
}

test('container renders without crashing', () => {
	const tree = setupContainer(initialContainerState);
	expect(tree).toMatchSnapshot();
});

// Set up card to be rendered
function setupCard(props) {
	return shallow(<SpecialEventsCard {...props} />);
}

test('card renders without crashing', () => {
	const tree = setupCard(initialCardState);
	expect(tree).toMatchSnapshot();
});
