import 'react-native';
import React from 'react';
import Enzyme, { shallow } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';

// Component to be tested
import { FeedbackView } from '../../../app/views/feedback/FeedbackView';

Enzyme.configure({ adapter: new Adapter() });

// Mock props passed down from state
const initialState = {
	timeoutFeedback: jest.fn(),
	feedback: {
		comment: '',
		name: '',
		email: '',
		commentHeight: 0,
		status: {
			requesting: false
		}
	}
};

// Set up component to be rendered
function setup(props) {
	return shallow(<FeedbackView {...props} />);
}

test('renders without crashing', () => {
	const tree = setup(initialState);
	expect(tree).toMatchSnapshot();
});

test('loading screen renders when requesting', () => {
	const loadingState = initialState;
	loadingState.feedback.status = {
		requesting: true,
		timeRequested: new Date()
	};
	const tree = setup(loadingState);
	expect(tree).toMatchSnapshot();
});

test('renders form when request is finished', () => {
	// Loading state while feedback posts
	const loadingState = initialState;
	loadingState.feedback.status = {
		requesting: true,
		timeRequested: new Date()
	};

	const tree = shallow(<FeedbackView {...loadingState} />);

	// Successful post state
	const successState = initialState;
	successState.feedback.status = {
		requesting: false,
		response: {}
	};

	tree.setProps(successState);
	expect(tree).toMatchSnapshot();

	// Failed post state
	const failingState = initialState;
	failingState.feedback.status = {
		requesting: false,
		error: {}
	};

	tree.setProps(failingState);
	expect(tree).toMatchSnapshot();
});
