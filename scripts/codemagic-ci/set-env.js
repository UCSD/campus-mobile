// set environment for specificed repo
const os = require('os')
const fs = require('fs')
const path = require('path')
const util = require('util')
const exec = util.promisify(require('child_process').exec)

// Config - See README
const config = require('./app-config.js')
const targetEnv = process.argv[2]
const appVersion = process.argv[3]
const buildNumber = process.argv[4]

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
const appVersionReplacements = async () => {
	try {
		config.APP_VERSION_REPLACEMENTS.forEach((envItem) => {
			fs.readFile(envItem.PATH, 'utf8', (err, data) => {
				const finalBuildNumber = parseInt(buildNumber) + 1000
				data = data.replaceAll('MARKETING_VERSION = 1.0.0;', 'MARKETING_VERSION = ' + appVersion + ';')
				data = data.replaceAll('CURRENT_PROJECT_VERSION = 1;', 'CURRENT_PROJECT_VERSION = ' + finalBuildNumber + ';')
				fs.writeFile(envItem.PATH, data, 'utf8', (err) => {
					if (err) throw err
					else console.log(envItem.PATH + ' --> ' + appVersion + ' (' + finalBuildNumber + ')')
				})
			})
		})
	} catch (err) {
		throw err
	}
}

try {
	if (targetEnv === 'PROD') {
		appVersionReplacements()
		prodEnvReplacements(targetEnv)
	} else if (targetEnv === 'PROD-TEST') {
		prodtestEnvReplacements(targetEnv)
	} else if (targetEnv === 'QA') {
		appVersionReplacements()
		qaEnvReplacements(targetEnv)
	} else {
		throw 'Sample usage: node set-env PROD|PROD-TEST|QA'
	}
} catch (err) {
	console.log('⚠ ERROR: Environment setup failed ⚠')
	console.log(err)
}
