const fetch = require('node-fetch')
const AbortController = require('abort-controller')
const moment = require('moment')
const fs = require('fs')
const download = require('download')
const XlsxTemplate = require('xlsx-template')
const spsave = require('spsave').spsave

const ENV_VARS = require('./env-vars.json')
const SP_CONFIG = require('./sp-config.json')

const controller = new AbortController()
const INTERNAL_ERROR = { 'error': 'An error occurred.' }

const generateTestPlan = async () => {
	try {
		console.log('Generating test plan for PR ' + ENV_VARS.prNumber)
		const prTestPlanFilename = 'PR-' + ENV_VARS.prNumber + '-Test-Plan.xlsx'
		const prTestPlanUrl = (SP_CONFIG.spSiteUrl + SP_CONFIG.spSiteFolder + prTestPlanFilename + '?web=1').replace(/ /g, '%20')

		console.log('Downloading PR test plan template ...')
		fs.writeFileSync(prTestPlanFilename, await download(SP_CONFIG.prTestPlanTemplateUrl))

		console.log('Making replacements ...')
		const data = fs.readFileSync(prTestPlanFilename)
		const template = new XlsxTemplate(data)
		const sheetNumber = 1
		const values = {
			PR_NUMBER: ENV_VARS.prNumber,
			APP_VERSION: ENV_VARS.appVersion,
			BUILD_ENV: ENV_VARS.buildEnv,
		}
		template.substitute(sheetNumber, values)
		fs.writeFileSync(prTestPlanFilename, Buffer.from(
			template.generate({type: 'base64'}),
			'base64'
		))

		console.log('Uploading test plan for PR ' + ENV_VARS.prNumber)
		const coreOptions = { siteUrl: SP_CONFIG.spSiteUrl }
		const fileOptions = {
			folder: SP_CONFIG.spSiteFolder,
			fileName: prTestPlanFilename,
			fileContent: fs.readFileSync(prTestPlanFilename)
		}
		await spsave(coreOptions, SP_CONFIG.credentials, fileOptions)

		return prTestPlanUrl
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
		const buildNumber = parseInt(ENV_VARS.buildNumber) + 1000
		let buildSuccess = (ENV_VARS.fciBuildStepStatus === 'success') ? true : false
		let buildApkUrl = ''
		let buildApkFile = ''
		let buildIpaUrl = ''
		let buildIpaFile = ''
		let prTestPlanUrl = ''
		let prTestPlanFilename = 'n/a'

		ENV_VARS.commitHash = ENV_VARS.commitHash.substring(0, 7)

		// If build success
		if (buildSuccess) {
			// Generate PR test plan
			if (ENV_VARS.prNumber) {
				prTestPlanUrl = await generateTestPlan()
				if (!prTestPlanUrl) {
					prTestPlanUrl = 'https://mobile.ucsd.edu/404'
				} else {
					prTestPlanFilename = prTestPlanUrl.replace(/(.*?)\//g, '').replace(/\?.*/g, '')
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
		teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Version:</b></td><td>' + ENV_VARS.appVersion + ' (' + buildNumber + ')</td></tr>'
		teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Environment:</b></td><td>' + ENV_VARS.buildEnv + '</td></tr>'

		if (ENV_VARS.prNumber) {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>PR:</b></td><td><a href="https://github.com/UCSD/campus-mobile/pull/' + ENV_VARS.prNumber + '" style="text-decoration:underline">' + ENV_VARS.prNumber + '</a></td></tr>'
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Testing:</b></td><td><a href="' + prTestPlanUrl + '" style="text-decoration:underline">' + prTestPlanFilename + '</a></td></tr>'
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

		console.log('\nSending Teams notification for v' + ENV_VARS.appVersion + ' (' + buildNumber + ')\n')

		// Send message via Teams webhook integration
		const abortTimeout = setTimeout(() => { controller.abort() }, timeout)
		const resp = await fetch(SP_CONFIG.webhookUrl, {
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
