import NearbyService from '../services/nearbyService';

function saveSearch(term) {
	return {
		type: 'SAVE_SEARCH',
		term
	};
}

function fetchSearch(term, location) {
	return (dispatch, getState) => {
		NearbyService.FetchSearchResults(term)
			.then((data) => {
				const results = data.results;

				dispatch({
					type: 'SET_SEARCH_RESULTS',
					results
				});

				// Save search to history if it was useful
				if (results) {
					dispatch(saveSearch(term));
				}

				return Promise.resolve();
			})
			.catch((error) => Promise.reject());
	};
}

module.exports = {
	saveSearch,
	fetchSearch,
};
