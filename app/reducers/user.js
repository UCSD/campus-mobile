const initialState = {
	isLoggedIn: false,
	profile: {
		username: null,
		classifications: null,
		pid: null,
		subscribedTopics: ['emergency', 'all', 'shuttle'],
	},
	syncedProfile: {},
	invalidSavedCredentials: false,
	appUpdateRequired: false,
	isStudentDemo: false,
	lastSynced: null,
}

function user(state = initialState, action) {
	const newState = { ...state }

	switch (action.type) {
		case 'LOGGED_IN': {
			const { profile } = action
			newState.isLoggedIn = true
			newState.profile = {
				...newState.profile,
				...profile
			}
			newState.invalidSavedCredentials = false
			return newState
		}
		case 'LOGGED_OUT': {
			return initialState
		}
		case 'PANIC_LOG_OUT': {
			const loggedOutState = initialState
			loggedOutState.invalidSavedCredentials = true
			return loggedOutState
		}
		case 'CLEAR_INVALID_CREDS_ERROR': {
			newState.invalidSavedCredentials = false
			return newState
		}
		case 'APP_UPDATE_REQUIRED': {
			newState.appUpdateRequired = true
			return newState
		}
		case 'ACTIVATE_STUDENT_DEMO_ACCOUNT': {
			newState.isStudentDemo = true
			return newState
		}
		case 'SET_LOCAL_PROFILE': {
			newState.profile = {
				...newState.profile,
				...action.profileItems,
			}
			return newState
		}
		case 'SET_USER_PROFILE': {
			newState.syncedProfile = {
				...newState.syncedProfile,
				...action.profileItems,
			}
			return newState
		}
		case 'PROFILE_SYNCED': {
			newState.lastSynced = new Date().getTime()
			return newState
		}
		case 'RESET_SYNCED_DATE': {
			newState.lastSynced = null
			return newState
		}
		default:
			return state
	}
}

module.exports = user
