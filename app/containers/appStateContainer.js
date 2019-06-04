import React from 'react'
import { AppState } from 'react-native'
import { connect } from 'react-redux'

class AppStateContainer extends React.Component {
	state = {
		appState: AppState.currentState
	}

	async componentDidMount() {
		AppState.addEventListener('change', this._handleAppStateChange)
	}

	componentWillUnmount() {
		AppState.removeEventListener('change', this._handleAppStateChange)
	}

	_handleAppStateChange = (nextAppState) => {
		if (this.state.appState.match(/inactive|background/) && nextAppState === 'active') {
			this.props.updateStudentProfile()
		}
		this.setState({ appState: nextAppState })
	}

	render() {
		this.props.updateStudentProfile()
		return null
	}
}

const mapDispatchToProps = (dispatch, ownProps) => (
	{
		updateStudentProfile: () => {
			dispatch({ type: 'UPDATE_STUDENT_PROFILE' })
		}
	}
)

module.exports = connect(null, mapDispatchToProps)(AppStateContainer)
