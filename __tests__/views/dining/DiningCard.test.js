import 'react-native';
import React from 'react';
import Enzyme, { shallow } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';

// Component to be tested
import { DiningCardContainer } from '../../../app/views/dining/DiningCardContainer';
import DataListCard from '../../../app/views/common/DataListCard';
import { DINING_RESPONSE } from '../../../mockApis/diningAPI';

Enzyme.configure({ adapter: new Adapter() });

// Mock props passed down from state
const initialContainerState = {
	diningData: DINING_RESPONSE,
	locationPermission: true
};

const initialCardState = {
	id: 'dining',
	title: 'Dining',
	data: DINING_RESPONSE,
	item: 'DiningItem'
};

// Set up container to be rendered
function setupContainer(props) {
	return shallow(<DiningCardContainer {...props} />);
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
