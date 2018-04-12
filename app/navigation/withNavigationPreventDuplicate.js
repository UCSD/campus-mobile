import deepDiffer from 'react-native/lib/deepDiffer'
import { NavigationActions, StateUtils } from 'react-navigation'

export const getActiveRouteForState = navigationState => (
	navigationState.routes
		? getActiveRouteForState(navigationState.routes[navigationState.index])
		: navigationState
)

export const isEqualRoute = (route1, route2) => {
	if (route1.routeName !== route2.routeName) {
		return false
	}

	return !deepDiffer(route1.params, route2.params)
}

export const areDuplicateRoots = (routesStack, nextRouteName) => {
	if (routesStack.length > 1 && routesStack[0].routes) {
		let duplicateRootFlag = false
		routesStack[0].routes.forEach((route) => {
			// if next route being navigated to is a tab
			// we should not render it because it will
			// add another duplicate tabview to the stack
			if (route.routeName === nextRouteName) duplicateRootFlag = true
		})
		return duplicateRootFlag
	}
	return false
}

const PATTERN_DRAWER_ROUTE_KEY = /^Drawer(Open|Close|Toggle)$/
export const isDrawerRoute = route => PATTERN_DRAWER_ROUTE_KEY.test(route.routeName)

const withNavigationPreventDuplicate = (getStateForAction) => {
	const defaultGetStateForAction = getStateForAction

	const getStateForActionWithoutDuplicates = (action, state) => {
		if (action.type === NavigationActions.NAVIGATE) {
			const previousRoute = getActiveRouteForState(StateUtils.back(state))
			const currentRoute = getActiveRouteForState(state)
			const nextRoute = action

			if (
				isDrawerRoute(currentRoute) &&
				(
					isEqualRoute(previousRoute, nextRoute) ||
					areDuplicateRoots(state.routes, nextRoute.routeName)
				)
			) {
				return StateUtils.back(state) // Close drawer
			}

			if (
				isEqualRoute(currentRoute, nextRoute) ||
				areDuplicateRoots(state.routes, nextRoute.routeName)
			) {
				return null
			}
		}

		return defaultGetStateForAction(action, state)
	}

	return getStateForActionWithoutDuplicates
}

export default withNavigationPreventDuplicate
