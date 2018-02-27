import {
	Keyboard
} from 'react-native';
import { ActionConst } from 'react-native-router-flux';

const initialState = {
	scene: {},
	onBoardingViewed: false
};

function routes(state = initialState, action) {
	const newState = { ...state };
	switch (action.type) {
	case ActionConst.FOCUS: {
		Keyboard.dismiss();

		return {
			...state,
			scene: action.scene
		};
	}
	case 'SET_ONBOARDING_VIEWED': {
		newState.onBoardingViewed = true;
		return newState;
	}
	default:
		return state;
	}
}

module.exports = routes;
