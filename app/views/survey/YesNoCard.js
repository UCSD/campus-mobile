import React from 'react'
import { View, Text } from 'react-native'

import Card from '../card/Card'
import Touchable from '../common/Touchable'
import css from '../../styles/css'

const YesNoCard = ({ style, question, id, data, onPress }) => (
	<Card
		id="question"
		title="Question"
	>
		<View style={css.survey_question_container}>
			<Text style={css.survey_question_text}>
				{question}
			</Text>
		</View>
		<View style={css.survey_answer_container}>
			<Touchable
				style={css.survey_button_container}
				onPress={() => onPress('yes')}
			>
				<Text style={css.survey_card_button_text}>Yes</Text>
			</Touchable>
			<Touchable
				style={css.survey_button_container}
				onPress={() => onPress('no')}
			>
				<Text style={css.survey_card_button_text}>No</Text>
			</Touchable>
		</View>
	</Card>
)

export default YesNoCard
