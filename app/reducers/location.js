
const initialState = {
	currentPosition: null,
	permission: false,
};

function location(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_LOCATION':
		newState.location = action.location;
		return newState;

	case 'SET_PERMISSION':
		newState.permission = action.permission;
		return newState;
	}

	return state;
}

module.exports = location;
