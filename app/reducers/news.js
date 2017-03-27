const initialState = {
	data: null,
	lastUpdated: new Date().getTime(),
};

function news(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_NEWS': {
		newState.data = action.news;

		return newState;
	}
	case 'SET_NEWS_UPDATE': {
		newState.lastUpdated = action.nowTime;

		return newState;
	}
	default:
		return state;
	}
}

module.exports = news;
