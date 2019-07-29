import { put, takeLatest, delay } from 'redux-saga/effects'

function* getMoviesFromApi() {
	try {
		yield put({ type: 'FETCH_MOVIES_REQUEST' })
		yield put({ type: 'SET_LOADING', isLoading: true })
		const response = yield fetch('https://facebook.github.io/react-native/movies.json')
		const responseJson = yield response.json()
		yield put({ type: 'FETCH_MOVIES_REQUEST_SUCCESS' })
		// just to be able to see the activity indicator we delay for 5 seconds
		yield delay(5000)
		yield put({ type: 'SET_MOVIES', movies: responseJson.movies })
		yield put({ type: 'SET_LOADING', isLoading: false })
	} catch (error) {
		yield put({ type: 'FETCH_MOVIES_REQUEST_FAIL' })
		yield put({ type: 'SET_LOADING', isLoading: false })
		console.error(error)
	}
}

function* mySaga() {
	yield takeLatest('GET_MOVIES', getMoviesFromApi)
}

export default mySaga