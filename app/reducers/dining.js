const initialState = {
	data: null,
	lastUpdated: 0,
};

function dining(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_DINING': {
		// create a lookup object for restaurant IDs
		const lookup = {};
		const dataWithLookup = action.data;

		for (let i = 0; i < action.data.length; i++) {
			lookup[action.data[i].id] = i;
		}

		dataWithLookup.lookup = lookup;

		newState.data = action.data;
		newState.lastUpdated = new Date().getTime();

		return newState;
	}
	case 'SET_DINING_MENU': {
		newState.data[action.id].menuItems = action.data;
		newState.data[action.id].menuItems.lastUpdated = new Date().getTime();

		return newState;
	}
	default:
		return state;
	}
}

module.exports = dining;
