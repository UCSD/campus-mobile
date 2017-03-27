const initialState = {
	data: null,
	lastUpdated: new Date().getTime(),
};

function surf(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_SURF':
		newState.data = action.surf;
		newState.lastUpdated = new Date().getTime();

		return newState;
	default:
		return state;
	}
}

module.exports = surf;
