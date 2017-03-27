import {
	Keyboard
} from 'react-native';
import { ActionConst } from 'react-native-router-flux';

const initialState = {
	scene: {},
};

function routes(state = initialState, action) {
	switch (action.type) {
	case ActionConst.FOCUS: {
		Keyboard.dismiss();

		return {
			...state,
			scene: action.scene
		};
	}
	default:
		return state;
	}
}

module.exports = routes;
