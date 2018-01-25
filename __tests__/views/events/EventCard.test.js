import 'react-native';
import React from 'react';
import Enzyme, { shallow } from 'enzyme';
import Adapter from 'enzyme-adapter-react-15.4';

// Component to be tested
import { EventCardContainer } from '../../../app/views/events/EventCardContainer';
import DataListCard from '../../../app/views/common/DataListCard';
import { EVENTS_RESPONSE } from '../../../mockApis/eventsApi';

Enzyme.configure({ adapter: new Adapter() });

// Mock props passed down from state
const initialContainerState = {
	eventsData: EVENTS_RESPONSE
};

const initialCardState = {
	id: 'events',
	title: 'Events',
	data: EVENTS_RESPONSE,
	item: 'EventsItem'
};

// Set up container to be rendered
function setupContainer(props) {
	return shallow(<EventCardContainer {...props} />);
}

test('container renders without crashing', () => {
	const tree = setupContainer(initialContainerState);
	expect(tree).toMatchSnapshot();
});

// Set up card to be rendered
function setupCard(props) {
	return shallow(<DataListCard {...props} />);
}

test('card renders without crashing', () => {
	const tree = setupCard(initialCardState);
	expect(tree).toMatchSnapshot();
});
