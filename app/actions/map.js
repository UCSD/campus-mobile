
function saveSearch(term) {
	return {
		type: 'SAVE_SEARCH',
		term
	};
}

module.exports = {
	saveSearch,
};
