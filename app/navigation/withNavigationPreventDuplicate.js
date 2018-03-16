import deepDiffer from 'react-native/lib/deepDiffer';
import { NavigationActions, StateUtils } from 'react-navigation';

export const getActiveRouteForState = navigationState => (
	navigationState.routes
		? getActiveRouteForState(navigationState.routes[navigationState.index])
		: navigationState
);

export const isEqualRoute = (route1, route2) => {
	if (route1.routeName !== route2.routeName) {
		return false;
	}

	return !deepDiffer(route1.params, route2.params);
};

const PATTERN_DRAWER_ROUTE_KEY = /^Drawer(Open|Close|Toggle)$/;
export const isDrawerRoute = route => PATTERN_DRAWER_ROUTE_KEY.test(route.routeName);

const withNavigationPreventDuplicate = (getStateForAction) => {
	const defaultGetStateForAction = getStateForAction;

	const getStateForActionWithoutDuplicates = (action, state) => {
		if (action.type === NavigationActions.NAVIGATE) {
			const previousRoute = getActiveRouteForState(StateUtils.back(state));
			const currentRoute = getActiveRouteForState(state);
			const nextRoute = action;

			if (isDrawerRoute(currentRoute) && isEqualRoute(previousRoute, nextRoute)) {
				return StateUtils.back(state); // Close drawer
			}

			if (isEqualRoute(currentRoute, nextRoute)) {
				return null;
			}
		}

		return defaultGetStateForAction(action, state);
	};

	return getStateForActionWithoutDuplicates;
};

export default withNavigationPreventDuplicate;
