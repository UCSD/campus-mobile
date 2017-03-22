import React from 'react';
import {
	View,
	Text,
	TouchableOpacity,
	StyleSheet
} from 'react-native';

import { connect } from 'react-redux';

import DismissibleCard from '../card/DismissibleCard';

const YesNoCard = ({ style, question, id, data, submitSurvey }) => (
	<DismissibleCard
		ref={(c) => { this._card = c; }}
		style={style}
	>
		<View style={styles.question_container}>
			<Text style={styles.question_text}>
				{question}
			</Text>
		</View>
		<View style={styles.answer_container}>
			<TouchableOpacity
				style={styles.button_container}
				onPress={() => {
					this._card.dismissCard();
					submitSurvey(id, 1, data); // 1 and 2 are values for dropdown
				}}
			>
				<Text style={styles.card_button_text}>Yes</Text>
			</TouchableOpacity>
			<TouchableOpacity
				style={styles.button_container}
				onPress={() => {
					this._card.dismissCard();
					submitSurvey(id, 2, data);
				}}
			>
				<Text style={styles.card_button_text}>No</Text>
			</TouchableOpacity>
		</View>
	</DismissibleCard>
);

const mapDispatchToProps = (dispatch) => ({
	submitSurvey: (id, answer, data) => {
		dispatch({ type: 'SURVEY_SUBMITTED', id, answer, data });
	}
});

const ActualYesNoCard = connect(
	null,
	mapDispatchToProps
)(YesNoCard);

const styles = StyleSheet.create({
	question_container: { justifyContent: 'center', alignItems: 'center', padding: 8, },
	question_text: { fontSize: 18, alignItems: 'center', textAlign: 'center' },
	card_button_text: { fontSize: 18, alignItems: 'center', textAlign: 'center' },
	answer_container: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', padding: 8 },
	button_container: { flex: 1, justifyContent: 'center', alignItems: 'center', },
});

export default ActualYesNoCard;
