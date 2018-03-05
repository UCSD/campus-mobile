import 'react-native';
import React from 'react';
import Enzyme, { shallow } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';

// Component to be tested
import { NewsCardContainer } from '../../../app/views/news/NewsCardContainer';
import DataListCard from '../../../app/views/common/DataListCard';
import { NEWS_RESPONSE } from '../../../mockApis/newsApi';

Enzyme.configure({ adapter: new Adapter() });

// Mock props passed down from state
const initialContainerState = {
	newsData: NEWS_RESPONSE
};

const initialCardState = {
	id: 'news',
	title: 'News',
	data: NEWS_RESPONSE,
	item: 'NewsItem'
};

// Set up container to be rendered
function setupContainer(props) {
	return shallow(<NewsCardContainer {...props} />);
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
