import React, { Component } from 'react'
import { Text, Linking, TouchableOpacity } from 'react-native'
import Icon from 'react-native-vector-icons/MaterialIcons'
import { connect } from 'react-redux'
import AccountInfo from './AccountInfo'
import AccountLogin from './AccountLogin'
import css from '../../../styles/css'
import Card from '../../common/Card'

class UserAccount extends Component {
	componentDidMount() {
		Linking.addEventListener('url', this._handleOpenURL)
	}

	componentWillUnmount() {
		Linking.removeEventListener('url', this._handleOpenURL)
	}

	_renderAccountContainer = mainText => (
		<TouchableOpacity
			style={css.ua_spacedRow}
			onPress={this._performUserAuthAction}
		>
			<Text style={css.ua_accountText}>{mainText}</Text>
			<Icon name="user" />
		</TouchableOpacity>
	)

	_renderAccountInfo = () => {
		// show the account info of logged in user, or not logged in
		if (this.props.user.isLoggedIn) {
			return this._renderAccountContainer(this.props.user.profile.name)
		} else {
			return this._renderAccountContainer('Tap to Log In')
		}
	}

	render() {
		const cardTitle = this.props.user.isLoggedIn ? 'Logged in as:' : 'Log in with SSO:'
		return (
			<Card id="user" title={cardTitle} style={css.card_full_container} hideMenu>
				{this.props.user.isLoggedIn ? (
					<AccountInfo />
				) : (
					<AccountLogin />
				)}
			</Card>
		)
	}
}

function mapStateToProps(state, props) {
	return { user: state.user }
}

export default connect(mapStateToProps)(UserAccount)
