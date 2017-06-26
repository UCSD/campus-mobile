import React from 'react';
import {
	ScrollView,
	Text,
	StyleSheet,
	TextInput,
	View,
} from 'react-native';
import { connect } from 'react-redux';

import {
	COLOR_MGREY,
	COLOR_WHITE,
	COLOR_PRIMARY,
} from '../../styles/ColorConstants';
import {
	MARGIN_TOP,
	MAX_CARD_WIDTH,
} from '../../styles/LayoutConstants';
import Card from '../card/Card';
import Touchable from '../common/Touchable';

const LoginView = ({ isLoggedIn }) => (
	<ScrollView
		style={styles.mainContainer}
	>
		<Card
			title="Login with SSO"
			hideMenu
		>
			{
				(isLoggedIn) ? (
					<View
						style={styles.contentContainer}
					>
						<Text>
							MyUsername
						</Text>
						<Touchable
							onPress={() => console.log('whatever')}
							style={styles.button}
						>
							<Text
								style={styles.buttonText}
							>
								Logout
							</Text>
						</Touchable>
					</View>
					) : (
						<View
							style={styles.contentContainer}
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
								style={styles.forgotButton}
							>
								<Text
									style={styles.forgotText}
								>
									Forgot password?
								</Text>
							</Touchable>
							<Touchable
								onPress={() => console.log('whatever')}
								style={styles.loginButton}
							>
								<Text
									style={styles.loginText}
								>
									Login
								</Text>
							</Touchable>
						</View>
				)
			}
		</Card>
	</ScrollView>
);

function mapStateToProps(state) {
	return {
		isLoggedIn: state.user.isLoggedIn
	};
}

const styles = StyleSheet.create({
	mainContainer: { flexGrow: 1, backgroundColor: COLOR_MGREY, marginTop: MARGIN_TOP },
	contentContainer: { flex: 1, margin: 8 },
	textInput: { height: 50, width: MAX_CARD_WIDTH - 16 },
	forgotButton: { flex: 1, justifyContent: 'center', alignItems: 'center', borderRadius: 3, padding: 10, },
	loginButton: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR_PRIMARY, borderRadius: 3, padding: 10, },
	forgotText: { fontSize: 16, color: COLOR_PRIMARY },
	loginText: { fontSize: 16, color: COLOR_WHITE },
});

export default connect(mapStateToProps)(LoginView);
