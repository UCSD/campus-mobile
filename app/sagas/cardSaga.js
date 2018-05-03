import { all, put, select, takeLatest } from 'redux-saga/effects'

const getCards = state => (state.cards)
const getUserData = state => (state.user)

function* showCard(action) {
	const { cards, cardOrder } = yield select(getCards)
	// Check if card already added
	let isCardAlreadyShown
	cardOrder.forEach((cardKey) => {
		if (cardKey === action.id) isCardAlreadyShown = true
	})

	if (!isCardAlreadyShown) {
		// Appends card to default position
		const { defaultPosition } = cards[action.id]
		yield put({ type: 'INSERT_CARD', id: action.id, position: defaultPosition })
	}
}

function* hideCard(action) {
	const { cardOrder } = yield select(getCards)
	let cardPosition
	cardOrder.forEach((card, index) => {
		if (card === action.id) cardPosition = index
	})

	// If card is not hidden, hide it
	if (cardPosition) {
		yield put({ type: 'REMOVE_CARD', id: action.id })
	}
}

function* reorderCard(action) {
	const { id, newIndex: newPosition } = action

	yield put({ type: 'REPOSITION_CARD', id, newPosition })
}

function* updateCard(action) {
	const { id, state } = action
	yield put({ type: 'SET_CARD_STATE', id, active: state })
}

function* updateAutoactivated(action) {
	const { id, state } = action
	yield put({ type: 'SET_AUTOACTIVATED_STATE', id, autoActivated: state })
}

function* toggleAuthCards() {
	const { cards } = yield select(getCards)
	const { isLoggedIn, profile } = yield select(getUserData)
	const authCards = []

	Object.keys(cards).forEach((cardKey) => {
		// If newly logged in, show cards that require auth
		// AND meet current users classifications
		if (isLoggedIn && cards[cardKey].authenticated) {
			if (cards[cardKey].classifications) {
				Object.keys(cards[cardKey].classifications).forEach((classification) => {
					if (profile.classifications[classification]) {
						authCards.push(cardKey)
					}
				})
			} else {
				authCards.push(cardKey)
			}
		} else if (!isLoggedIn) {
			// Remove all cards that require authentication
			if (cards[cardKey].authenticated) {
				authCards.push(cardKey)
			}
		}
	})

	if (isLoggedIn) {
		// show cards
		yield all(authCards.map(cardKey => put({ type: 'SHOW_CARD', id: cardKey })))
	} else {
		// hide cards
		yield all(authCards.map(cardKey => put({ type: 'HIDE_CARD', id: cardKey })))
	}
}

function* cardSaga() {
	yield takeLatest('SHOW_CARD', showCard)
	yield takeLatest('HIDE_CARD', hideCard)
	yield takeLatest('REORDER_CARD', reorderCard)
	yield takeLatest('UPDATE_CARD_STATE', updateCard)
	yield takeLatest('UPDATE_AUTOACTIVATED_STATE', updateAutoactivated)
	yield takeLatest('TOGGLE_AUTHENTICATED_CARDS', toggleAuthCards)
}

export default cardSaga
