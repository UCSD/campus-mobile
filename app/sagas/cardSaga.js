import { call, fork, put, select, takeLatest } from 'redux-saga/effects';

const getCards = (state) => (state.cards);

function* orderCards(action) {
	try {
		const { newOrder } = action;
		if (newOrder && newOrder.length > 0) {
			yield put({ type: 'SET_CARD_ORDER', cardOrder: newOrder });
		}
	} catch (error) {
		console.log('Error re-ordering cards: ' + error);
	}
}

function* updateCard(action) {
	const { id, state } = action;

	yield put({ type: 'SET_CARD_STATE', id, active: state });
}

function* cardSaga() {
	yield takeLatest('ORDER_CARDS', orderCards);
	yield takeLatest('UPDATE_CARD_STATE', updateCard);
}

export default cardSaga;
