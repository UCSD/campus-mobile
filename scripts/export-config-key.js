const os = require('os')

const CONFIG_KEY = process.argv[2]
const ENV_TYPE = process.argv[3]

if (CONFIG_KEY) {
	if (ENV_TYPE === 'ci') {
		const APP_CONFIG = JSON.parse(process.env.APP_CONFIG.replace(/\\\"/g,'"')) // eslint-disable-line
		if (APP_CONFIG[CONFIG_KEY]) {
			console.log(APP_CONFIG[CONFIG_KEY])
		}
	} else {
		const myEnv = require(os.homedir() + '/.campusmobile/config.js') // eslint-disable-line
		if (myEnv.APP_CONFIG[CONFIG_KEY]) {
			console.log(myEnv.APP_CONFIG[CONFIG_KEY])
		}
	}
} else {
	console.log('Error: Config key not specififed.')
}
