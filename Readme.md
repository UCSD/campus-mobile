[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)
# Campus Mobile app

The campus mobile app platform enables the university to deliver relevant information to students, staff, and visitors, taking the context of time and location into consideration. The platform uses [React Native](https://facebook.github.io/react-native/) and implements a card based UI.

The goal of this platform is to provide a responsive and intuitive native mobile interactions for a personalized campus experience.

UC San Diego uses this platform for its campus mobile app on iOS and Android.

## Getting Started

- Follow the [Getting Started guide](https://facebook.github.io/react-native/docs/getting-started.html) for React Native

- Install From the project folder, run:
	npm install
	npm run-script apply-fixes

## Manual Bug Fixes
[Pressing same tab](https://github.com/UCSD/campus-mobile/issues/134)
[Preference Switches](https://github.com/UCSD/campus-mobile/issues/159)

## Building for Android

	react-native run-android

## Building for iOS

	react-native run-ios

## Documentation

Review the [modules documentation](https://htmlpreview.github.io/?https://raw.githubusercontent.com/UCSD/campus-mobile/dev/out/index.html)

## Available Cards
* TopBanner
	* For upcoming current events
* Weather & Surf
	* 5 day weather report
	* Surf report link
* Shuttle
	* Nearest shuttle stops and arrival times
	* Shuttle stop details
* Dining
	* Nearest dining options with menu and nutritional information
	* View all dining link
* Events
	* Upcoming events
	* View all events link
* Links
	* A list of helpful links from our legacy app
	* View all quick links link
* News
	* Latest news articles
	* View all news link
* Maps
	* Searchable campus map
	* View all link


## Screenshots
![Alt text](/../screenshots/screenshots/splash.png?raw=true "Splash Screen")

![Alt text](/../screenshots/screenshots/weather.png?raw=true "Weather")

![Alt text](/../screenshots/screenshots/events.png?raw=true "Events")

![Alt text](/../screenshots/screenshots/news.png?raw=true "News")

![Alt text](/../screenshots/screenshots/dining.png?raw=true "Dining")

![Alt text](/../screenshots/screenshots/nearby.png?raw=true "Nearby Places")

![Alt text](/../screenshots/screenshots/shuttle_detail.png?raw=true "Shuttle Detail")

![Alt text](/../screenshots/screenshots/all_events.png?raw=true "All Events")


## License

	MIT
