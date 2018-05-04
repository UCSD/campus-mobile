/* Credit for this reducer goes to StashAway! Incredibly helpful post:
* https://medium.com/stashaway-engineering/react-redux-tips-better-way
* -to-handle-loading-flags-in-your-reducers-afda42a804c6
*/

function requestErrors(state = {}, action) {
	const {
		type,
		error,
	} = action
	const matches = /(.*)_(REQUEST|FAILURE|SUCCESS)/.exec(type)

	// not a *_REQUEST, *_SUCCESS, or *_FAILURE action, ignore
	if (!matches) return state

	const [, requestName, requestState] = matches
	return {
		...state,
		// Store error
		// e.g. stores errorMessage when receiving FAILURE
		// else clears error message when receiving REQUEST / SUCCESS
		[requestName]: requestState === 'FAILURE' ? error.message : null
	}
}

module.exports = requestErrors
