import React from 'react';
import {
	View,
	Text,
} from 'react-native';
import DiningHours from './DiningHours';
import moment from 'moment';

import css from '../../styles/css';

const DiningDescription = ({
	name, description, regularHours, specialHours, paymentOptions
}) => {
	let paymentOptionsText = null;
	if (paymentOptions) {
		paymentOptions.forEach((option) => {
			if (!paymentOptionsText) {
				paymentOptionsText = option;
			} else {
				paymentOptionsText += `, ${option}`;
			}
		});
	}

	return (
		<View style={css.dd_description_container}>
			<Text style={css.dd_description_nametext}>{name}</Text>
			{description
				? <Text style={css.dd_description_subtext}>{description}</Text>
				: null
			}

			<Text style={css.dd_description_subtext}>Hours:</Text>
			<DiningHours
				hours={regularHours}
			/>

			{specialHours[moment().format('MM/DD/YYYY')] ?
			(
				<View>
					<Text style={css.dd_description_subtext}>
						Special hours:
					</Text>
					<DiningHours
						hours={specialHours}
						specialHours
					/>
				</View>
			) : null
			}

			{paymentOptionsText
				?
				(
					<View>
						<Text style={css.dd_description_subtext}>Payment Options:</Text>
						<Text>{paymentOptionsText}</Text>
					</View>
				)
				: null
			}
		</View>
	);
};

export default DiningDescription;
