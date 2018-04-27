import React from 'react';
import {
	ScrollView,
	StyleSheet,
} from 'react-native';
import { connect } from 'react-redux';

import {
	COLOR_MGREY,
} from '../../styles/ColorConstants';
import {
	MARGIN_TOP,
} from '../../styles/LayoutConstants';
import UserAccount from './UserAccount';

const LoginView = ({ isLoggedIn }) => (
	<ScrollView
		style={styles.mainContainer}
		keyboardShouldPersistTaps="handled"
	>
		<UserAccount />
	</ScrollView>
);

function mapStateToProps(state) {
	return {
		isLoggedIn: state.user.isLoggedIn
	};
}

const styles = StyleSheet.create({
	mainContainer: { flexGrow: 1, backgroundColor: COLOR_MGREY, marginTop: MARGIN_TOP },
});

export default connect(mapStateToProps)(LoginView);
