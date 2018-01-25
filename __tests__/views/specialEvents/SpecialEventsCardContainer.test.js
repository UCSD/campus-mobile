import 'react-native';
import React from 'react';
import Enzyme, { shallow } from 'enzyme';
import Adapter from 'enzyme-adapter-react-15.4';

// Component to be tested
import { SpecialEventsCardContainer } from '../../../app/views/specialEvents/SpecialEventsCardContainer';

Enzyme.configure({ adapter: new Adapter() });

// Mock props passed down from state
const initialState = {
	specialEventsData: {
		'name': 'Campus Lisa',
		'location': 'Wells Fargo Hall, UC San Diego Rady School of Management',
		'start-time': '1484064000000',
		'end-time': '1527706800000',
		'logo': 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/images/v1/campus_lisa_2017_logo.png',
		'logo-sm': 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/images/v1/campus_lisa_2017_logo_sm.png',
		'map': 'https://campuslisa.ucsd.edu/_images/conference-map.jpg',
		'uids': [
			'1'
		],
		'schedule': {
			'1': {
				'id': '1',
				'start-time': '1527667200000',
				'end-time': '1527669000000',
				'talk-type': 'Default',
				'top-label': 'No',
				'label': '',
				'label-theme': '',
				'location': 'Rady School of Management Courtyard',
				'talk-title': 'Check-in/Registration',
				'speaker-shortdesc': '',
				'full-description': 'Test Description'
			}
		},
		'dates': [
			'2018-05-30'
		],
		'date-items': {
			'2018-05-30': [
				'1'
			]
		},
		'labels': [
			'Miscellaneous'
		],
		'label-items': {
			'Miscellaneous': [
				'1'
			]
		},
		'label-themes': {
			'Miscellaneous': '#747678'
		}
	},
	saved: [],
	hideCard: jest.fn()
};

// Set up component to be rendered
function setup(props) {
	return shallow(<SpecialEventsCardContainer {...props} />);
}

test('renders without crashing', () => {
	const tree = setup(initialState);
	expect(tree).toMatchSnapshot();
});
