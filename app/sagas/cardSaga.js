import { all, put, select, takeLatest } from 'redux-saga/effects'

const getCards = state => (state.cards)
const getUserData = state => (state.user)

function* showCard(action) {
	const { cardOrder } = yield select(getCards)

	// If card isn't already present in card stack
	if (cardOrder.indexOf(action.id) < 0) {
		// Appends card to top of cards stack
		yield put({ type: 'INSERT_CARD', id: action.id, position: 0 })
	}
}

function* hideCard(action) {
	const { cardOrder } = yield select(getCards)
	const cardPosition = cardOrder.indexOf(action.id)

	// If card is present in cardstest stack, hide it
	if (cardPosition >= 0) {
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
		// AND meet current users classifications AND
		// are autoactivated
		if (
			isLoggedIn &&
			cards[cardKey].authenticated &&
			cards[cardKey].autoActivated !== false
		) {
			if (cards[cardKey].classifications) {
				Object.keys(cards[cardKey].classifications).forEach((classification) => {
					// Checks to make sure it isn't adding a duplicate card
					// if multiple classifications are met
					if (profile.classifications[classification] && authCards.indexOf(cardKey) < 0) {
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
