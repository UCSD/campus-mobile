import {
	put,
	select,
	takeLatest,
	call,
} from 'redux-saga/effects'

import fetchSearchResults from '../services/nearbyService'

const getMap = state => (state.map)

function* fetchSearch(action) {
	const { term, location } = action
	const results = yield call(fetchSearchResults, term, location)
	// Save search to history if it was useful
	if (Array.isArray(results) && results.length > 0) {
		yield put({ type: 'ADD_HISTORY', term })
		yield put({ type: 'SET_SEARCH_RESULTS', results })
	} else {
		yield put({ type: 'SET_SEARCH_RESULTS', results: null })
	}
}

function* clearSearch(action) {
	yield put({ type: 'SET_SEARCH_RESULTS', results: null })
}

function* addHistory(action) {
	const { history } = yield select(getMap)
	let newHistory = history.slice()
	const { term } = action.term
	const termIndex = newHistory.indexOf(action.term)
	if ( termIndex !== -1) {
		// Move term to front of array if it's already in there
		newHistory = [...newHistory.splice(termIndex, 1), ...newHistory]
	} else {
		newHistory = [term, ...newHistory]
	}
	yield put({ type: 'UPDATE_HISTORY', history: newHistory })
}

function* removeHistory(action) {
	const { history } = yield select(getMap)
	const newHistory = history.slice()
	const { index } = action
	newHistory.splice(index, 1)
	yield put({ type: 'UPDATE_HISTORY', history: newHistory })
}

function* mapSaga() {
	yield takeLatest('ADD_HISTORY', addHistory)
	yield takeLatest('REMOVE_HISTORY', removeHistory)
	yield takeLatest('FETCH_MAP_SEARCH', fetchSearch)
	yield takeLatest('CLEAR_MAP_SEARCH', clearSearch)
}

export default mapSaga
