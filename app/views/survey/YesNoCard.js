import React from 'react';
import {
	View,
	Text,
	TouchableOpacity,
	StyleSheet
} from 'react-native';

import Card from '../card/Card';
import Touchable from '../common/Touchable';
import { COLOR_DGREY } from '../../styles/ColorConstants';

const YesNoCard = ({ style, question, id, data, onPress }) => (
	<Card
		id="question"
		title="Question"
	>
		<View style={styles.question_container}>
			<Text style={styles.question_text}>
				{question}
			</Text>
		</View>
		<View style={styles.answer_container}>
			<Touchable
				style={styles.button_container}
				onPress={() => onPress('yes')}
			>
				<Text style={styles.card_button_text}>Yes</Text>
			</Touchable>
			<Touchable
				style={styles.button_container}
				onPress={() => onPress('no')}
			>
				<Text style={styles.card_button_text}>No</Text>
			</Touchable>
		</View>
	</Card>
);

const styles = StyleSheet.create({
	question_container: { justifyContent: 'center', alignItems: 'center', padding: 8, },
	question_text: { color: COLOR_DGREY, fontSize: 18, alignItems: 'center', },
	card_button_text: { color: COLOR_DGREY, fontSize: 18, alignItems: 'center', textAlign: 'center' },
	answer_container: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', padding: 8 },
	button_container: { flex: 1, justifyContent: 'center', alignItems: 'center', },
});

export default YesNoCard;
