const fetch = require('node-fetch')
const AbortController = require('abort-controller')
const moment = require('moment')
const fs = require('fs')
const download = require('download')
const XlsxTemplate = require('xlsx-template')
const spsave = require('spsave').spsave
const ENV_VARS = require('./env-vars.json')
const SP_CONFIG = require('./sp-config.json')

const INTERNAL_ERROR = { 'error': 'An error occurred.' }
const finalBuildNumber = parseInt(ENV_VARS.buildNumber) + 1000

const generateTestPlan = async (prAuthor) => {
	try {
		let testPlanFilename
		let testPlanUrl
		if (ENV_VARS.prNumber) {
			console.log('Generating test plan for PR ' + ENV_VARS.prNumber)
			testPlanFilename = 'PR-' + ENV_VARS.prNumber + '-Test-Plan-' + ENV_VARS.appVersion + '-' + ENV_VARS.buildEnv + '-' + finalBuildNumber + '.xlsx'
			testPlanUrl = (SP_CONFIG.spSiteUrl + SP_CONFIG.spPullRequestTestFolder + testPlanFilename + '?web=1').replace(/ /g, '%20')
			console.log('  (1/3) Downloading PR test plan template ...')
			fs.writeFileSync(testPlanFilename, await download(SP_CONFIG.prTestPlanTemplateUrl))
		} else {
			console.log('Generating regression test plan for branch ' + ENV_VARS.buildBranch)
			testPlanFilename = 'Regression-Test-Plan-' + ENV_VARS.appVersion + '-' + ENV_VARS.buildEnv + '-' + finalBuildNumber + '.xlsx'
			testPlanUrl = (SP_CONFIG.spSiteUrl + SP_CONFIG.spRegressionTestFolder + testPlanFilename + '?web=1').replace(/ /g, '%20')
			switch(ENV_VARS.buildEnv) {
				case 'PROD':
					console.log('  (1/3) Downloading PROD regression test plan template ...')
					fs.writeFileSync(testPlanFilename, await download(SP_CONFIG.prodRegressionTestPlanTemplateUrl))
					break
				case 'PROD-TEST':
					console.log('  (1/3) Downloading PROD-TEST regression test plan template ...')
					fs.writeFileSync(testPlanFilename, await download(SP_CONFIG.prodtestRegressionTestPlanTemplateUrl))
					break
				default:
					console.log('  (1/3) Downloading QA regression test plan template ...')
					fs.writeFileSync(testPlanFilename, await download(SP_CONFIG.qaRegressionTestPlanTemplateUrl))
			}
		}

		console.log('  (2/4) Making replacements ...')
		const data = fs.readFileSync(testPlanFilename)
		const template = new XlsxTemplate(data)
		const sheetNumber = 1
		const values = {
			APP_VERSION: ENV_VARS.appVersion,
			BUILD_ENV: ENV_VARS.buildEnv,
			BUILD_NUMBER: finalBuildNumber,
			BUILD_BRANCH: ENV_VARS.buildBranch,
		}
		if (ENV_VARS.prNumber) {
			values.PR_AUTHOR = prAuthor
			values.PR_NUMBER = ENV_VARS.prNumber
		}

		template.substitute(sheetNumber, values)

		console.log('  (3/4) Writing ' + testPlanFilename)
		fs.writeFileSync(testPlanFilename, Buffer.from(
			template.generate({type: 'base64'}),
			'base64'
		))

		console.log('  (4/4) Uploading test plan for build ' + finalBuildNumber)
		const coreOptions = { siteUrl: SP_CONFIG.spSiteUrl }
		const fileOptions = {
			folder: ENV_VARS.prNumber ? SP_CONFIG.spPullRequestTestFolder : SP_CONFIG.spRegressionTestFolder,
			fileName: testPlanFilename,
			fileContent: fs.readFileSync(testPlanFilename)
		}
		await spsave(coreOptions, SP_CONFIG.credentials, fileOptions)
		return {
			testPlanFilename: testPlanFilename,
			testPlanUrl: testPlanUrl,
		}
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
		let prAuthor = ''

		ENV_VARS.commitHash = ENV_VARS.commitHash.substring(0, 7)

		// Supplemental GitHub API Metadata for PRs
		if (ENV_VARS.prNumber) {
			console.log('Fetching GitHub metadata for PR ' + ENV_VARS.prNumber)
			const ghController = new AbortController()
			const ghTimeout = setTimeout(() => { ghController.abort() }, timeout)
			const ghResp = await fetch('https://api.github.com/repos/UCSD/campus-mobile/pulls/' + ENV_VARS.prNumber, {
				signal: ghController.signal,
			})
			const ghRespJson = await ghResp.json()
			clearTimeout(ghTimeout)
			if (ghResp.statusText != 'OK') {
				throw 'Error: Unable to GET GitHub metadata for PR ' + ENV_VARS.prNumber + ' (status: ' + ghResp.statusText + ')'
			}
			prAuthor = ghRespJson.user.login
		}

		// Generate test plan
		const { testPlanFilename, testPlanUrl } = await generateTestPlan(prAuthor)

		// Extract APK and IPA artifacts
		ENV_VARS.fciArtifactLinks.forEach((artifact, index) => {
			if (artifact.name === 'app-release.apk' && artifact.url) {
				buildApkUrl = artifact.url
				buildApkFile = artifact.name
			} else if (artifact.name === 'UC_San_Diego.ipa' && artifact.url) {
				buildIpaUrl = artifact.url
				buildIpaFile = artifact.name.replace('_', '&#95;')
			}
		})



		// Construct build notifier message
		let teamsMessage = '#### Campus Mobile Build Notifier\n\n'
		teamsMessage += '<table border="0" style="margin:16px">'
		teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Version:</b></td><td>' + ENV_VARS.appVersion + ' (' + finalBuildNumber + ')</td></tr>'
		teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Environment:</b></td><td>' + ENV_VARS.buildEnv + '</td></tr>'

		// PR or Branch
		if (ENV_VARS.prNumber) {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>PR:</b></td><td><a href="https://github.com/UCSD/campus-mobile/pull/' + ENV_VARS.prNumber + '" style="text-decoration:underline">' + ENV_VARS.prNumber + '</a></td></tr>'
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Author:</b></td><td>' + prAuthor + '</td></tr>'
		} else {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Branch:</b></td><td>' + ENV_VARS.buildBranch + '</td></tr>'
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Commit:</b></td><td><a href="https://github.com/UCSD/campus-mobile/commit/' + ENV_VARS.commitHash + '" style="text-decoration:underline">' + ENV_VARS.commitHash + '</a></td></tr>'
		}

		teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Testing:</b></td><td><a href="' + testPlanUrl + '" style="text-decoration:underline">' + testPlanFilename + '</a></td></tr>'

		// Build Artifacts
		if (buildIpaUrl) {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>iOS:</b></td><td>TestFlight ' + ENV_VARS.appVersion + ' (' + finalBuildNumber + ')</td></tr>'
		}
		if (buildApkUrl) {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Android:</b></td><td><a href="' + buildApkUrl + '" download style="text-decoration:underline">' + buildApkFile + '</a></td></tr>'
		}

		// Build Success or Failure
		if (buildSuccess) {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Status:</b></td><td><span style="color:green">SUCCESS</span> (<a href="' + fciProjectLink + '" style="text-decoration:underline">detail</a>)</td></tr>'
		} else {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Status:</b></td><td><span style="color:red">FAILURE</span> (<a href="' + fciProjectLink + '" style="text-decoration:underline">detail</a>)</td></tr>'
		}

		teamsMessage += '<tr><td align="right"><b>Time:</b></td><td width="320">' + buildTimestamp + '</td></tr>'
		teamsMessage += '</table>'

		// Send notification via webhook integration
		console.log('Sending Teams notification for v' + ENV_VARS.appVersion + ' (' + finalBuildNumber + ')\n')
		const notifyController = new AbortController()
		const notifyTimeout = setTimeout(() => { notifyController.abort() }, timeout)
		const notifyResp = await fetch(SP_CONFIG.webhookUrl, {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({
				'text': teamsMessage
			}),
			signal: notifyController.signal,
		})
		clearTimeout(notifyTimeout)

		if (notifyResp.statusText != 'OK') {
			throw 'Error: Unable to POST to webhookUrl (status: ' + notifyResp.statusText + ')'
		}
	} catch (err) {
		console.log(err)
		process.exitCode = 1
	}
}

buildNotify()
