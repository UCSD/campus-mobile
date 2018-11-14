import 'react-native'
import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

// Component to be tested
import PreferencesView from '../../../app/views/preferences/Preferences'

Enzyme.configure({ adapter: new Adapter() })

// Mock props passed down from state
const initialState = {

}

// Set up component to be rendered
function setup(props) {
	return shallow(<PreferencesView {...props} />)
}

test('renders without crashing', () => {
	const tree = setup(initialState)
	expect(tree).toMatchSnapshot()
})
