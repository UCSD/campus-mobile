## now@ucsandiego.app

## License

	MIT

## Installation

	// From project folder run:
	npm install

	// Link third party modules with rnpm
	rnpm link

	// Modify react-native-maps to fix a recent issue introduced in RN 0.29
	in AIRMapCallout.h, line 7
	change:
		#import "React/RCTView.h"
	to:
		#import "RCTView.h"

	in AIRMap.h, line 12
	change:
		#import <React/RCTComponent.h>
	to:
		#import <RCTComponent.h>

