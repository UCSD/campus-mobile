import React from 'react'
import { View, Text } from 'react-native'
import { withNavigation } from 'react-navigation'
import Icon from 'react-native-vector-icons/Ionicons'
import logger from '../../util/logger'
import Touchable from '../common/Touchable'
import { getHumanizedDuration } from '../../util/general'
import css from '../../styles/css'
import COLOR from '../../styles/ColorConstants'

const SpecialEventsItem = ({
	navigation,
	specialEventsData,
	saved,
	add,
	remove,
	title
}) => (
	<View style={css.sei_itemRow}>
		<CircleBorder />
		<View style={css.sei_titleContainer}>
			<Touchable
				onPress={() => navigation.navigate('SpecialEventsDetailView', { data: specialEventsData, title, add, remove })}
			>
				<View>
					{specialEventsData['talk-title'] ? (
						<Text
							style={css.sei_titleText}
						>
							{specialEventsData['talk-title']}
						</Text>
					) : null }

					<View style={css.sei_labelView}>
						{ specialEventsData.label ? (
							<Text style={[css.sei_labelText, { color: specialEventsData['label-theme'] ? specialEventsData['label-theme'] : COLOR.BLACK }]}>{specialEventsData.label}</Text>
						) : null }
						{ specialEventsData.label || specialEventsData['talk-type'] === 'Keynote' ? (
							<Text style={css.sei_labelText}> - </Text>
						) : null }
						<Text style={css.sei_labelText}>{getHumanizedDuration(specialEventsData['start-time'], specialEventsData['end-time'])}</Text>
					</View>
				</View>
			</Touchable>
		</View>

		{ (add !== null) ? (
			<Touchable
				style={css.sei_starButton}
				onPress={() => (saved ? (
					removeSession(remove, specialEventsData.id, specialEventsData['talk-title'])
				) : (
					addSession(add, specialEventsData.id, specialEventsData['talk-title'])
				))}
			>
				<View style={css.sei_starButtonInner}>
					<Icon
						name="ios-star-outline"
						size={32}
						style={css.sei_starOuterIcon}
					/>
					{ saved ? (
						<Icon
							name="ios-star"
							size={26}
							style={css.sei_starInnerIcon}
						/>
					) : null }
				</View>
			</Touchable>
		) : null }
	</View>
)

const CircleBorder = () => (
	<View style={css.sei_borderContainer}>
		<View style={css.sei_line} />
		<View style={css.sei_circle} />
	</View>
)

const removeSession = (remove, id, title) => {
	remove(id)
		logger.trackEvent('SpecialEvents', { SessionRemoved: title })
}

const addSession = (add, id, title) => {
	add(id)
	logger.trackEvent('SpecialEvents', { SessionAdded: title })
}

const wrappedSpecialEventsItem = withNavigation(SpecialEventsItem)
export default wrappedSpecialEventsItem
