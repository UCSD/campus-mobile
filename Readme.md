# Campus Mobile app

The campus mobile app platform enables the university to deliver relevant information to students, staff, and visitors, taking the context of time and location into consideration. The platform uses [React Native](https://facebook.github.io/react-native/) and implements a card based UI.

The goal of this platform is to provide a responsive and intuitive native mobile interactions for a personalized campus experience.

UC San Diego uses this platform for its campus mobile app on iOS and Android.

## Getting Started

- Follow the [Getting Started guide](https://facebook.github.io/react-native/docs/getting-started.html) for React Native 
- From the project folder, run:
	- npm install
	- npm run-script apply-fixes
- For iOS, from the project folder, run: react-native run-ios
- For Android, from the project folder, run: react-native run-android

## Documentation

Review the [modules documentation](https://htmlpreview.github.io/?https://raw.githubusercontent.com/UCSD/campus-mobile/dev/out/index.html)

## Building for Android

[Utility script](https://github.com/UCSD/campus-mobile-build-scripts) to create an APK. This build script exists in a repository separate from the campus mobile app repository.

	// From an empty directory
	//Build APK one liner:
	git clone https://github.com/UCSD/campus-mobile-build-scripts.git && cd campus-mobile-build-scripts && npm install && node build-apk.js

	//Build APK and install on device one liner:
	git clone https://github.com/UCSD/campus-mobile-build-scripts.git && cd campus-mobile-build-scripts && npm install && node build-apk.js && adb install ./bld/android/app/build/outputs/apk/app-release.apk

## Building for iOS

TODO: add content

## Availabile Cards
* TopBanner
	* For upcoming current events
* Weather & Surf
	* 5 day weather report
	* Surf report link
* Shuttle
	* Nearest shuttle stops and arrival times
	* Shuttle stop info to view all shuttles en route
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