const fetch = require('node-fetch')
const AbortController = require('abort-controller')
const moment = require('moment')
const fs = require('fs')
const download = require('download')
const XlsxTemplate = require('xlsx-template')
const spsave = require('spsave').spsave

const ENV_VARS = require('./env-vars.json')
const SP_AUTH = require('./sp-auth.json')

const controller = new AbortController()
const INTERNAL_ERROR = { 'error': 'An error occurred.' }

const generateSmoketest = async () => {
	try {
		console.log('Generating smoke test for PR ' + ENV_VARS.prNumber)
		const spSiteUrl = 'https://ucsdcloud.sharepoint.com/sites/WorkplaceTechnologyServices-CampusMobileBuildsTest/'
		const spSiteFolder = 'Shared Documents/Campus Mobile Builds Test/Pull Request Testing/'
		const prSmokeTestTemplateURL = 'https://ucsd-its-wts-dev.s3-us-west-1.amazonaws.com/replatform/v1/testing/PR-Smoke-Test-Template-v1.xlsx'
		const prSmokeTestFilename = 'PR-' + ENV_VARS.prNumber + '-Smoke-Test.xlsx'
		const prSmokeTestUrl = (spSiteUrl + spSiteFolder + prSmokeTestFilename + '?web=1').replace(/ /g, '%20')

		console.log('Downloading PR smoke test template ...')
		fs.writeFileSync(prSmokeTestFilename, await download(prSmokeTestTemplateURL))

		console.log('Making replacements ...')
		const data = fs.readFileSync(prSmokeTestFilename)
		const template = new XlsxTemplate(data)
		const sheetNumber = 1
		const values = {
			PR_NUMBER: ENV_VARS.prNumber,
			APP_VERSION: ENV_VARS.appVersion,
			BUILD_ENV: ENV_VARS.buildEnv,
		}
		template.substitute(sheetNumber, values)
		fs.writeFileSync(prSmokeTestFilename, Buffer.from(
			template.generate({type: 'base64'}),
			'base64'
		))

		console.log('Uploading smoke test for PR ' + ENV_VARS.prNumber)
		const coreOptions = { siteUrl: spSiteUrl }
		const fileOptions = {
			folder: spSiteFolder,
			fileName: prSmokeTestFilename,
			fileContent: fs.readFileSync(prSmokeTestFilename)
		}
		await spsave(coreOptions, SP_AUTH, fileOptions)

		return prSmokeTestUrl
	} catch(err) {
		console.log(err)
		return null
	}
}

const buildNotify = async () => {
	try {
		const buildTimestamp = moment().format('YYYY-MM-DD h:mm A')
		const timeout = 15000 // Abort request after 15 seconds
		const fciProjectLink = 'https://codemagic.io/app/' + ENV_VARS.fciProjectId + '/build/' + ENV_VARS.fciBuildId
		let buildSuccess = (ENV_VARS.fciBuildStepStatus === 'success') ? true : false
		let buildApkUrl = ''
		let buildApkFile = ''
		let buildIpaUrl = ''
		let buildIpaFile = ''
		let prSmokeTestUrl = ''
		let prSmokeTestFilename = 'n/a'

		ENV_VARS.appVersion += '.' + ENV_VARS.buildNumber
		ENV_VARS.commitHash = ENV_VARS.commitHash.substring(0, 7)

		// If build success
		if (buildSuccess) {
			// Generate PR smoke test
			if (ENV_VARS.prNumber) {
				prSmokeTestUrl = await generateSmoketest()
				if (!prSmokeTestUrl) {
					prSmokeTestUrl = 'https://mobile.ucsd.edu/404'
				} else {
					prSmokeTestFilename = prSmokeTestUrl.replace(/(.*?)\//g, '').replace(/\?.*/g, '')
				}
			}

			// Extract APK and IPA artifacts
			if (Array.isArray(ENV_VARS.fciArtifactLinks)) {
				ENV_VARS.fciArtifactLinks.forEach((artifact, index) => {
					if (artifact.name === 'app-release.apk' && artifact.url) {
						buildApkUrl = artifact.url
						buildApkFile = artifact.name
					} else if (artifact.name === 'UC_San_Diego.ipa' && artifact.url) {
						buildIpaUrl = artifact.url
						buildIpaFile = artifact.name.replace('_', '&#95;')
					}
				})
			}
		}

		// // Construct build notifier message
		let teamsMessage = '#### Campus Mobile Build Notifier\n\n'
		teamsMessage += '<table border="0" style="margin:16px">'
		teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Version:</b></td><td>' + ENV_VARS.appVersion + '</td></tr>'
		teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Environment:</b></td><td>' + ENV_VARS.buildEnv + '</td></tr>'

		if (ENV_VARS.prNumber) {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>PR:</b></td><td><a href="https://github.com/UCSD/campus-mobile/pull/' + ENV_VARS.prNumber + '" style="text-decoration:underline">' + ENV_VARS.prNumber + '</a></td></tr>'
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Testing:</b></td><td><a href="' + prSmokeTestUrl + '" style="text-decoration:underline">' + prSmokeTestFilename + '</a></td></tr>'
		} else {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Branch:</b></td><td>' + ENV_VARS.buildBranch + '</td></tr>'
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Commit:</b></td><td><a href="https://github.com/UCSD/campus-mobile/commit/' + ENV_VARS.commitHash + '" style="text-decoration:underline">' + ENV_VARS.commitHash + '</a></td></tr>'
		}
		if (buildIpaUrl) {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>IPA:</b></td><td><a href="' + buildIpaUrl + '" download style="text-decoration:underline">' + buildIpaFile + '</a></td></tr>'
		}
		if (buildApkUrl) {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>APK:</b></td><td><a href="' + buildApkUrl + '" download style="text-decoration:underline">' + buildApkFile + '</a></td></tr>'
		}
		// Build success or failure
		if (buildSuccess) {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Build:</b></td><td><span style="color:green">SUCCESS</span> (<a href="' + fciProjectLink + '" style="text-decoration:underline">detail</a>)</td></tr>'
		} else {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Build:</b></td><td><span style="color:red">FAILURE</span> (<a href="' + fciProjectLink + '" style="text-decoration:underline">detail</a>)</td></tr>'
		}

		teamsMessage += '<tr><td align="right"><b>Time:</b></td><td width="260">' + buildTimestamp + '</td></tr>'
		teamsMessage += '</table>'
		if (buildApkUrl) {
			teamsMessage += '<a href="' + buildApkUrl + '" download><img src="https://mobile.ucsd.edu/_images/apk-download.png" width="172" height="76"></a>'
		}

		console.log('\nSending Teams notification for v' + ENV_VARS.appVersion + ' (' + ENV_VARS.buildNumber + ')\n')

		// Send message via Teams webhook integration
		const abortTimeout = setTimeout(() => { controller.abort() }, timeout)
		const resp = await fetch(ENV_VARS.webhookUrl, {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({
				'text': teamsMessage
			}),
			signal: controller.signal,
		})
		clearTimeout(abortTimeout)

		if (resp.statusText != 'OK') {
			throw 'Error: Unable to POST to webhookUrl (status: ' + resp.statusText + ')'
		}
	} catch (err) {
		console.log(err)
		process.exitCode = 1
	}
}

buildNotify()
