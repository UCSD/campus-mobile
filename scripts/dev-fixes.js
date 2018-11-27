/*
	Usage:
	npm run dev-fixes
*/
const fs = require('fs')
const shell = require('shelljs')

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

// Configure Glog
shell.cd('node_modules/react-native')
shell.exec('scripts/ios-install-third-party.sh')
shell.cd('third-party/glog-0.3.4')
shell.exec('./configure')
shell.cd('../../../../')

// Fix an issue with libfishhook.a linking
const LIBFH_PATH = './node_modules/react-native/Libraries/WebSocket/RCTWebSocket.xcodeproj/project.pbxproj'
const LIBFH_OLD_1 = '13526A521F362F7F0008EF00'
const LIBFH_OLD_2 = '13526A511F362F7F0008EF00'
const LIBFH_NEW_1 = '2D3ABDC220C7206E00DF56E9'
const LIBFH_NEW_2 = '3DBE0D001F3B181A0099AA32'
makeReplacements(LIBFH_PATH, [
	{ initial: LIBFH_OLD_1, fixed: LIBFH_NEW_1 },
	{ initial: LIBFH_OLD_2, fixed: LIBFH_NEW_2 }
])
