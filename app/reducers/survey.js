const initialState = {
	byId: {},
	allIds: [],
	doneIds: [],
	lastAnswered: 0,
}

function survey(state = initialState, action) {
	const newState = { ...state }

	switch (action.type) {
		case 'SURVEY_DONE': {
			const arr = newState.doneIds.slice()
			arr.push(action.id)
			newState.doneIds = arr
			newState.lastAnswered = new Date().getTime()

			return newState
		}
		case 'SET_SURVEY_IDS': {
			newState.allIds = action.surveyIds
			return newState
		}
		case 'SET_SURVEY': {
			newState.byId = Object.assign({}, newState.byId)
			newState.byId[action.id] = action.survey
			return newState
		}
		default:
			return state
	}
}

module.exports = survey
