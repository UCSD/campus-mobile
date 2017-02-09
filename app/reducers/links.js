const initialState = {
	data: null,
	lastUpdated: new Date().getTime(),
};

function links(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_LINKS': {
		newState.data = action.links;

		return newState;
	}
	case 'SET_LINKS_UPDATE': {
		newState.lastUpdated = action.nowTime;

		return newState;
	}
	default:
		return state;
	}
}

module.exports = links;
