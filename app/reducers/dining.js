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

		return Object.assign({}, newState, {
			data: dataWithLookup,
			lastUpdated: new Date().getTime()
		});
	}
	case 'SET_DINING_MENU': {
		const newDataArray = newState.data;
		newDataArray[action.id].menuItems = action.data;
		newDataArray[action.id].menuItems.lastUpdated = new Date().getTime();
		const newData = Object.assign({}, newState, {
			data: newDataArray
		});

		return newData;
	}
	default:
		return state;
	}
}

module.exports = dining;
