import { NavigationActions } from 'react-navigation'

let _navigator

const NavigationService = {
	setTopLevelNavigator(navigatorRef) {
		_navigator = navigatorRef
	},
	navigate(routeName, params) {
		_navigator.dispatch(NavigationActions.navigate({ routeName, params }))
	},
}

export default NavigationService