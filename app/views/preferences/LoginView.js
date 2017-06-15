import React from 'react';
import {
	ScrollView,
	Text,
	StyleSheet,
	TextInput,
} from 'react-native';

import {
	COLOR_MGREY,
	COLOR_WHITE,
	COLOR_PRIMARY,
} from '../../styles/ColorConstants';
import {
	MARGIN_TOP
} from '../../styles/LayoutConstants';
import Card from '../card/Card';
import Touchable from '../common/Touchable';

const LoginView = () => (
	<ScrollView
		style={styles.mainContainer}
	>
		<Card
			title="Login"
			hideMenu
		>
			<TextInput
				style={styles.textInput}
				autofocus
				autoCorrect={false}
				placeholder="Username"
				onSubmitEditing={() => this._passwordInput.focus()}
			/>
			<TextInput
				ref={(c) => { this._passwordInput = c; }}
				style={styles.textInput}
				placeholder="Password"
				secureTextEntry
			/>
			<Touchable
				onPress={() => console.log('whatever')}
				style={styles.button}
			>
				<Text
					style={styles.buttonText}
				>
					Login
				</Text>
			</Touchable>
		</Card>
	</ScrollView>
);

const styles = StyleSheet.create({
	mainContainer: { flexGrow: 1, backgroundColor: COLOR_MGREY, marginTop: MARGIN_TOP },
	textInput: { height: 50 },
	button: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR_PRIMARY, borderRadius: 3, padding: 10, margin: 8 },
	buttonText: { fontSize: 16, color: COLOR_WHITE },
});

export default LoginView;
