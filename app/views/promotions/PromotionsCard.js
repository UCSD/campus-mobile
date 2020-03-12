import React from 'react'
import { View } from 'react-native'
import { withNavigation } from 'react-navigation'
import { openURL } from '../../util/general'
import BannerCard from '../common/BannerCard'

export const PromotionsCard = ({ navigation, promoFeed, hideCard }) => (
	<View>
		<BannerCard
			showButton={!(promoFeed['event-type'] === 'Promo Banner')}
			title={(promoFeed.name) ? promoFeed.name : promoFeed.eventname}
			image={(promoFeed.logo) ? promoFeed.logo : promoFeed['banner-image']}
			onPress={() => {
				if (promoFeed['event-type'] === 'Promo Banner') {
					const array = promoFeed['banner-url'].split('://')
					if (array[0] === 'app') {
						navigation.navigate(array[1])
					} else {
						if ( promoFeed['banner-url'].length > 0 ) openURL(promoFeed['banner-url'])
					}
				}
			}}
			onClose={() => hideCard('specialEvents')}
		/>
	</View>
)

export default withNavigation(PromotionsCard)
