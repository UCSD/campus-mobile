import { put, takeEvery } from 'redux-saga/effects'
import { yieldExpression } from '@babel/types';

function* updateInput(action) {
  const { input } = action;
  yield put({ type: 'UPDATE_SEARCH_INPUT', searchInput: input})
}

function* changeFilterStatus(action) {
  const { showFilter } = action;
  yield put({ type: 'CHANGE_FILTER_STATUS', filterVisible: showFilter})
}

function* updateFiterValue(action) {
  const { filterVal } = action;
  yield put({ type: 'UPDATE_FILTER', filterVal: filterVal})
}


export default function* courseSage() {
  yield takeEvery('UPDATE_INPUT', updateInput);
  yield takeEvery('CHANGE_FILTER_VISIBILITY', changeFilterStatus)
  yield takeEvery('UPDATE_FILTER_VALUE', updateFiterValue)
}