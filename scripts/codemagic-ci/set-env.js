// set environment for specificed repo
const os = require('os')
const fs = require('fs')
const path = require('path')
const util = require('util')
const exec = util.promisify(require('child_process').exec)

// Config - See README
const config = require('./app-config.js')
const targetEnv = process.argv[2]


// File Replacements
const prodFileReplacements = async (targetEnv) => {
	try {
		config.PROD_FILE_REPLACEMENTS.forEach((fileItem, index) => {
			fs.copyFile(
				fileItem.PROD,
				fileItem.PATH,
				(err) => {
					if (err) throw err
					else console.log(fileItem.PATH + ' --> ' + targetEnv)
				}
			)
		})
	} catch (err) {
		throw err
	}
}

const qaFileReplacements = async (targetEnv) => {
	try {
		config.QA_FILE_REPLACEMENTS.forEach((fileItem, index) => {
			fs.copyFile(
				fileItem.QA,
				fileItem.PATH,
				(err) => {
					if (err) throw err
					else console.log(fileItem.PATH + ' --> ' + targetEnv)
				}
			)
		})
	} catch (err) {
		throw err
	}
}

// Environment Replacements
const prodEnvReplacements = async (targetEnv) => {
	try {
		config.PROD_ENV_REPLACEMENTS.forEach((envItem) => {
			fs.readFile(envItem.PATH, 'utf8', (err, data) => {
				envItem.QA.forEach((replacement, index) => {
					// Debug endpoints
					// console.log('replacement: ' + replacement + ', index: ' + index)
					data = data.replace(replacement, envItem.PROD[index])
				})
				fs.writeFile(envItem.PATH, data, 'utf8', (err) => {
					if (err) throw err
					else console.log(envItem.PATH + ' --> ' + targetEnv)
				})
			})
		})
	} catch (err) {
		throw err
	}
}

const prodtestEnvReplacements = async (targetEnv) => {
	try {
		config.PRODTEST_ENV_REPLACEMENTS.forEach((envItem) => {
			fs.readFile(envItem.PATH, 'utf8', (err, data) => {
				envItem.PROD.forEach((replacement, index) => {
					data = data.replace(replacement, envItem.QA[index])
				})
				fs.writeFile(envItem.PATH, data, 'utf8', (err) => {
					if (err) throw err
					else console.log(envItem.PATH + ' --> ' + targetEnv)
				})
			})
		})
	} catch (err) {
		throw err
	}
}

const qaEnvReplacements = async (targetEnv) => {
	try {
		config.QA_ENV_REPLACEMENTS.forEach((envItem) => {
			fs.readFile(envItem.PATH, 'utf8', (err, data) => {
				envItem.QA.forEach((replacement, index) => {
					// Debug endpoints
					// console.log('replacement: ' + replacement + ', index: ' + index)
					data = data.replace(replacement, envItem.PROD[index])
				})
				fs.writeFile(envItem.PATH, data, 'utf8', (err) => {
					if (err) throw err
					else console.log(envItem.PATH + ' --> ' + targetEnv)
				})
			})
		})
	} catch (err) {
		throw err
	}
}

// App Version Replacements
const appVersionReplacements = async (targetEnv, buildIncrement) => {
	try {
		config.APP_VERSION_REPLACEMENTS.forEach((envItem) => {
			fs.readFile(envItem.PATH, 'utf8', (err, data) => {
				const [appVersion, appBuildNumber] = envItem.APP_VERSION.split('+')
				let prodAppBuildNumber = parseInt(appBuildNumber) + buildIncrement
				const prodAppVersion = appVersion + '+' + prodAppBuildNumber
				data = data.replace(envItem.APP_VERSION, prodAppVersion)
				fs.writeFile(envItem.PATH, data, 'utf8', (err) => {
					if (err) throw err
					else console.log(envItem.PATH + ' --> ' + targetEnv)
				})
			})
		})
	} catch (err) {
		throw err
	}
}

try {
	if (targetEnv === 'PROD') {
		// appVersionReplacements(targetEnv, 2)
		// prodFileReplacements(targetEnv)
		prodEnvReplacements(targetEnv)
	} else if (targetEnv === 'PROD-TEST') {
		// appVersionReplacements(targetEnv, 1)
		prodtestEnvReplacements(targetEnv)
	} else if (targetEnv === 'QA') {
		// appVersionReplacements(targetEnv, 0)
		// qaFileReplacements(targetEnv)
		qaEnvReplacements(targetEnv)
	} else {
		throw 'Sample usage: node set-env PROD|PROD-TEST|QA'
	}
} catch (err) {
	console.log('⚠ ERROR: Environment setup failed ⚠')
	console.log(err)
}
