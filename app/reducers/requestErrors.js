/* Credit for this reducer goes to StashAway! Incredibly helpful post:
* https://medium.com/stashaway-engineering/react-redux-tips-better-way
* -to-handle-loading-flags-in-your-reducers-afda42a804c6
*/

function requestErrors(state = {}, action) {
	const {
		type,
		error,
	} = action
	const matches = /(.*)_(REQUEST|FAILURE)/.exec(type)

	// not a *_REQUEST or *_FAILURE action, ignore
	if (!matches) return state

	const [, requestName, requestState] = matches
	return {
		...state,
		// Store error
		// e.g. stores errorMessage when receiving POST_FEEDBACK_FAILURE
		// else clears error message when receiving POST_FEEDBACK_REQUEST
		[requestName]: requestState === 'FAILURE' ? error.message : null
	}
}

module.exports = requestErrors
