import React from 'react'
import { View } from 'react-native'
import { withNavigation } from 'react-navigation'

import BannerCard from '../common/BannerCard'

export const SpecialEventsCard = ({ navigation, specialEvents, saved, hideCard }) => (
	<View>
		<BannerCard
			title={specialEvents.name}
			image={specialEvents.logo}
			onPress={() => navigation.navigate('SpecialEventsView', { title: specialEvents.name, personal: false })}
			onClose={() => hideCard('specialEvents')}
		/>
	</View>
)

export default withNavigation(SpecialEventsCard)
