import React from 'react'
import { View } from 'react-native'
import { withNavigation } from 'react-navigation'
import { openURL } from '../../util/general'
import BannerCard from '../common/BannerCard'

export const SpecialEventsCard = ({ navigation, specialEvents, saved, hideCard }) => (
	<View>
		<BannerCard
			showButton={!(specialEvents['event-type'] === 'Promo Banner')}
			title={(specialEvents.name) ? specialEvents.name : specialEvents.eventname}
			image={(specialEvents.logo) ? specialEvents.logo : specialEvents['banner-image']}
			onPress={() => {
				if (specialEvents['event-type'] === 'Promo Banner') {
					const array = specialEvents['banner-url'].split('://')
					if (array[0] === 'app') {
						navigation.navigate(array[1])
					} else {
						openURL(specialEvents['banner-url'])
					}
				} else {
					navigation.navigate('SpecialEventsView', { title: specialEvents.name, personal: false })
				}
			}}
			onClose={() => hideCard('specialEvents')}
		/>
	</View>
)

export default withNavigation(SpecialEventsCard)
