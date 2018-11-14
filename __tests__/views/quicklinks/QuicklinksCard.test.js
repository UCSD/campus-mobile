import 'react-native'
import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

// Component to be tested
import { QuicklinksCardContainer } from '../../../app/views/quicklinks/QuicklinksCardContainer'
import { DataListCard } from '../../../app/views/common/DataListCard'
import general from '../../../app/util/general'
import { QUICKLINKS_RESPONSE } from '../../../mockApis/quicklinksApi'

Enzyme.configure({ adapter: new Adapter() })

// Mock props passed down from state
const initialContainerState = {
	linksData: QUICKLINKS_RESPONSE
}

const initialCardState = {
	id: 'quicklinks',
	title: 'Links',
	data: QUICKLINKS_RESPONSE,
	rows: 4,
	item: 'QuicklinksItem',
	cardSort: general.dynamicSort('card-order')
}

// Set up container to be rendered
function setupContainer(props) {
	return shallow(<QuicklinksCardContainer {...props} />)
}

test('container renders without crashing', () => {
	const tree = setupContainer(initialContainerState)
	expect(tree).toMatchSnapshot()
})

// Set up card to be rendered
function setupCard(props) {
	return shallow(<DataListCard {...props} />)
}

test('card renders without crashing', () => {
	const tree = setupCard(initialCardState)
	expect(tree).toMatchSnapshot()
})
