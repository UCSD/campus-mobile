import React, { Component } from 'react'
import {
	View,
	Text,
} from 'react-native'

import Icon from 'react-native-vector-icons/Ionicons'
import { withNavigation } from 'react-navigation'
import ColoredDot from '../common/ColoredDot'
import Touchable from '../common/Touchable'
import { COLOR } from '../../styles/ColorConstants'
import css from '../../styles/css'

const general = require('../../util/general')
const dining = require('../../util/dining')

class DiningItem extends Component {
	componentDidMount() {
		this.interval = setInterval(() => this.forceUpdate(), 950)
	}

	componentWillUnmount() {
		clearInterval(this.interval)
	}

	render() {
		const { navigation, data } = this.props

		if (!data.name) return null
		const status = dining.getOpenStatus(data.regularHours)
		const areSpecialHours = data.specialHours
		let activeDotColor,
			statusText,
			soonStatusText,
			soonStatusColor,
			newHourElement

		if (status) {
			if (status.isValid) {
				activeDotColor = status.isOpen ?
					COLOR.MGREEN : COLOR.MRED

				statusText = status.isOpen ?
					'Open' : 'Closed'
			} else {
				statusText = 'Unknown'
			}

			soonStatusText = null
			soonStatusColor = null
			if (status.openingSoon) {
				soonStatusText = 'Opening Soon'
				soonStatusColor = COLOR.MGREEN
			}
			else if (status.closingSoon) {
				soonStatusText = 'Closing Soon'
				soonStatusColor = COLOR.MRED
			}

			const isClosed = (!status.currentHours)
			const isAlwaysOpen = (
				status.currentHours &&
				status.currentHours === 'Open 24/7'
			)
			let newHourElementHoursText
			if (!status.isValid) {
				newHourElementHoursText = 'Unknown hours'
			}
			else if (isClosed) {
				newHourElementHoursText = 'Closed today'
			}
			else if (isAlwaysOpen) {
				newHourElementHoursText = 'Open 24 Hours'
			}
			else if (
				status.currentHours.openingHour.format('h:mm a') !== 'Invalid date'
				&& status.currentHours.closingHour.format('h:mm a') !== 'Invalid date'
			) {
				let openingHourAmPm = 'a.m.'
				if (status.currentHours.openingHour.format('a') === 'pm') {
					openingHourAmPm = 'p.m.'
				}
				let closingHourAmPm = 'a.m.'
				if (status.currentHours.closingHour.format('a') === 'pm') {
					closingHourAmPm = 'p.m.'
				}
				newHourElementHoursText = status.currentHours.openingHour.format('h:mm ')
					+ openingHourAmPm
					+ ' — '
					+ status.currentHours.closingHour.format('h:mm ')
					+ closingHourAmPm
			} else {
				newHourElementHoursText = 'Unknown hours'
			}
			newHourElement = (
				<View>
					<Text style={css.dl_hours_text}>
						{newHourElementHoursText}
					</Text>
				</View>
			)
		} else {
			statusText = 'Unknown'
			newHourElement = (
				<View>
					<Text style={css.dl_hours_text}>Unknown Hours</Text>
				</View>
			)
		}

		return (
			<View style={css.dl_row}>
				<Touchable
					style={css.dl_row_container_left}
					onPress={() => navigation.navigate('DiningDetail', { data })}
				>
					<View style={css.dl_title_row}>
						<Text style={css.dl_title_text}>{data.name}</Text>
					</View>
					{
						(!areSpecialHours) ? (
							<View>
								<View style={css.dl_status_row}>
									<ColoredDot
										size={10}
										color={activeDotColor}
										style={css.dl_status_icon}
									/>
									<Text style={[css.dl_status_text, { color: activeDotColor }]}>
										{statusText}
									</Text>
								</View>
								<View style={css.dl_hours_row}>
									{newHourElement}
									<Text
										style={[
											css.dl_status_soon_text,
											{ color: soonStatusColor }
										]}
									>
										{soonStatusText}
									</Text>
								</View>
							</View>
						) : (
							<View style={css.dl_hours_row}>
								<Text style={css.dl_status_disclaimer}>
									{'Today\'s hours may be impacted by a special event.'}
								</Text>
							</View>
						)
					}
				</Touchable>

				{( data.coords && data.coords.lat !== 0) ? (
					<Touchable
						style={css.dl_row_container_right}
						onPress={() => general.gotoNavigationApp(data.coords.lat, data.coords.lon)}
					>
						<View style={css.dl_dir_traveltype_container}>
							<Icon name="md-walk" size={32} color={COLOR.PRIMARY} />
							{data.distanceMilesStr ? (
								<Text style={css.dl_dir_eta}>{data.distanceMilesStr}</Text>
							) : null }
						</View>
					</Touchable>
				) : (
					(data.address) ? (
						<Touchable
							style={css.dl_row_container_right}
							onPress={() => general.gotoNavigationApp(null, null, data.address)}
						>
							<View style={css.dl_dir_traveltype_container}>
								<Icon name="md-walk" size={32} color={COLOR.PRIMARY} />
							</View>
						</Touchable>
					) : (null)
				) }
			</View>
		)
	}
}

export default withNavigation(DiningItem)
