import React from 'react'
import { Text } from 'react-native'
import { withNavigation } from 'react-navigation'
import NavigationService from '../../navigation/NavigationService'

import ScrollCard from '../common/ScrollCard'
import Touchable from '../common/Touchable'
import css from '../../styles/css'

export const WebRegCard = ({
	navigation,
	updateScroll,
	lastScroll,
}) => {
	const extraActions = [
		{
			name: 'Test Action',
			action: () => {}
		}
	]

	return (
		<ScrollCard
			id="webreg"
			title="WebReg"
			scrollData={[]}
			renderItem={() => {}}
			actionButton={
				<Touchable
					style={css.shuttlecard_addButton}
					onPress={() => NavigationService.navigate('CourseSearch')}
				>
					<Text style={css.shuttlecard_addText}>View Courses</Text>
				</Touchable>
			}
			extraActions={extraActions}
			updateScroll={updateScroll}
			lastScroll={lastScroll}
		/>
	)
}

export default withNavigation(WebRegCard)
