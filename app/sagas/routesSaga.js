import { put, takeLatest } from 'redux-saga/effects';

function* setOnboardingViewed(action) {
  console.log('settingonboarding')
	yield put({ type: 'SET_ONBOARDING', viewed: action.viewed });
}

function* routesSaga() {
	yield takeLatest('SET_ONBOARDING_VIEWED', setOnboardingViewed);
}

export default routesSaga;
