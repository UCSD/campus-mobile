import React from 'react'
import {
	View,
	Text,
} from 'react-native'
import DiningHours from './DiningHours'

import css from '../../styles/css'

const DiningDescription = ({
	name, description, regularHours, specialHours, paymentOptions
}) => {
	let paymentOptionsText = null
	if (paymentOptions) {
		paymentOptions.forEach((option) => {
			if (!paymentOptionsText) {
				paymentOptionsText = option
			} else {
				paymentOptionsText += `, ${option}`
			}
		})
	}

	return (
		<View style={css.dd_description_container}>
			<Text style={css.dd_description_nametext}>{name}</Text>
			{description
				? <Text style={css.dd_description_text}>{description}</Text>
				: null
			}

			<Text style={css.dd_description_subtext}>Hours:</Text>
			{
				(specialHours) ?
					(
						<Text style={css.dd_hours_text_disclaimer}>
							Special hours may be in effect; Status and hours displayed below may not be accurate.
						</Text>
					) : null
			}
			<DiningHours
				hours={regularHours}
			/>

			{(specialHours) ?
				(
					<DiningHours
						hours={specialHours}
						specialHours
					/>
				) : null
			}

			{paymentOptionsText
				?
				(
					<View>
						<Text style={css.dd_description_subtext}>Payment Options:</Text>
						<Text style={css.dd_description_po}>{paymentOptionsText}</Text>
					</View>
				)
				: null
			}
		</View>
	)
}

export default DiningDescription
