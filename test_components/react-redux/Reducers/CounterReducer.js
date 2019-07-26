import * as Actions from '../Actions/ActionTypes'

const initialState = {
	someKey: 'someValue',
	count: 0
}

const CounterReducer = (state = initialState ,action) => {
	switch (action.type) {
		case Actions.COUNTER_INCREMENT:
			return {
				...state,
				count: state.count + 1
			}
		case Actions.COUNTER_DECREMENT:
			return {
				...state,
				count: state.count - 1
			}
		default:
			return state
	}
}
export default CounterReducer