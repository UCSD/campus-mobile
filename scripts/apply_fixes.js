/*
	Usage:
	npm run-script apply-fixes
*/
const fs = require('fs')

// Fix an issue with Android default text color
const TEXT_FIX_PATH = './node_modules/react-native/Libraries/Text/Text.js'
const TEXT_ERR = 'if \\(this.context.isInAParentText\\)'
const TEXT_FIX = 'newProps = {...newProps, style: [{color: \'black\'}, this.props.style] }\n    if (this.context.isInAParentText)'

// Set correct safe area for iPhone XR
const XR_FIX_PATH = './node_modules/react-native-safe-area-view/index.js'
const XR_FIX_REPL1 = 'const X_HEIGHT = 812;'
const XR_FIX_REPL1_FIX = 'const X_HEIGHT = 812;const XSMAX_WIDTH = 414;const XSMAX_HEIGHT = 896;'
const XR_FIX_REPL2 = '\\(D_HEIGHT === X_WIDTH && D_WIDTH === X_HEIGHT\\)\\)'
const XR_FIX_REPL2_FIX = '\(D_HEIGHT === X_WIDTH && D_WIDTH === X_HEIGHT\)\) || \(\(D_HEIGHT === XSMAX_HEIGHT && D_WIDTH === XSMAX_WIDTH\) || \(D_HEIGHT === XSMAX_WIDTH && D_WIDTH === XSMAX_HEIGHT\)\)'
const XR_FIX_REPL3 = 'return DeviceInfo.isIPhoneX_deprecated;'
const XR_FIX_REPL3_FIX = '//return DeviceInfo.isIPhoneX_deprecated;'

const makeReplacements = (FILE_PATH, REPLACEMENTS) => {
	fs.readFile(FILE_PATH, 'utf8', (readErr, data) => {
		if (readErr) {
			return console.log(readErr)
		} else {
			for (let i = 0; REPLACEMENTS.length > i; i++) {
				data = data.replace(new RegExp(REPLACEMENTS[i].initial, 'g'), REPLACEMENTS[i].fixed)
			}

			fs.writeFile(FILE_PATH, data, 'utf8', (writeErr) => {
				if (writeErr) {
					return console.log(writeErr)
				} else {
					console.log('SUCCESS: File ' + FILE_PATH + ' updated with fixed value.')
				}
			})
		}
	})
}

makeReplacements(TEXT_FIX_PATH, [
	{ initial: TEXT_ERR, fixed: TEXT_FIX }
])

makeReplacements(XR_FIX_PATH, [
	{ initial: XR_FIX_REPL1, fixed: XR_FIX_REPL1_FIX },
	{ initial: XR_FIX_REPL2, fixed: XR_FIX_REPL2_FIX },
	{ initial: XR_FIX_REPL3, fixed: XR_FIX_REPL3_FIX }
])
