/*
	Usage:
	npm run-script apply-fixes
*/
const fs = require('fs')

// Fix an issue with Android default text color
const TEXT_FIX_PATH = './node_modules/react-native/Libraries/Text/Text.js'
const TEXT_ERR = 'if \\(this.context.isInAParentText\\)'
const TEXT_FIX = 'newProps = {...newProps, style: [{color: \'black\'}, this.props.style] }\n    if (this.context.isInAParentText)'

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
