import { put, takeEvery } from 'redux-saga/effects'



function* updateInput(action) {
  const { input } = action;
  yield put({ type: 'UPDATE_SEARCH_INPUT', searchInput: input})
}

function* changeFilterStatus(action) {
  const { showFilter } = action;
  yield put({ type: 'CHANGE_FILTER_STATUS', filterVisible: showFilter})
}


export default function* courseSage() {
  yield takeEvery('UPDATE_INPUT', updateInput);
  yield takeEvery('CHANGE_FILTER_VISIBILITY', changeFilterStatus)
}