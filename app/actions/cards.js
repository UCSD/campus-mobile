
function hideCard(id) {
	return {
		type: 'HIDE_CARD',
		id
	};
}

function showCard(id) {
	console.log('show card');
	return {
		type: 'SHOW_CARD',
		id
	};
}

function setCardState(card, state) {
	if (state === true) {
		return showCard(card);
	} else {
		return hideCard(card);
	}
}

module.exports = {
	hideCard,
	showCard,
	setCardState
};
