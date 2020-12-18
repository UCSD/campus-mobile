const fetch = require('node-fetch')
const AbortController = require('abort-controller')
const moment = require('moment')

const controller = new AbortController()
const INTERNAL_ERROR = { 'error': 'An error occurred.' }

const appVersion = process.argv[2]
const buildNumber = process.argv[3]
const buildEnv = process.argv[4]
const webhookUrl = process.argv[5]
const fciArtifactLinks = JSON.parse(process.argv[6])
const buildBranch = process.argv[7]
const prNumber = process.argv[8]

const buildNotify = async (appVersion, buildNumber, buildEnv, webhookUrl, fciArtifactLinks, buildBranch = 'n/a', commitHash = 'n/a', prNumber = '') => {
	try {
		const buildTimestamp = moment().format('YYYY-MM-DD h:mm A')
		const timeout = 15000 // Abort request after 15 seconds

		let buildApkUrl = ''
		let buildApkFile = ''
		let buildIpaUrl = ''
		let buildIpaFile = ''

		appVersion += '.' + buildNumber

		console.log('fciArtifactLinks:')
		console.log(fciArtifactLinks)

		let teamsMessage = '#### Campus Mobile Build Notifier\n\n'

		fciArtifactLinks.forEach((artifact, index) => {
			if (artifact.name === 'app-release.apk' && artifact.url) {
				buildApkUrl = artifact.url
				buildApkFile = artifact.name
			} else if (artifact.name === 'UC_San_Diego.ipa' && artifact.url) {
				buildIpaUrl = artifact.url
				buildIpaFile = artifact.name.replace('_', '&#95;')
			}
		})

		teamsMessage += '<table border="0" style="margin:16px">'
		teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Version:</b></td><td>' + appVersion + '</td></tr>'
		// teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Build:</b></td><td>' + buildNumber + '</td></tr>'
		teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Env:</b></td><td>' + buildEnv + '</td></tr>'
		teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Branch:</b></td><td><a href="https://github.com/UCSD/campus-mobile/tree/' + buildBranch + '">' + buildBranch + '</a></td></tr>'
		if (prNumber) {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>PR:</b></td><td><a href="https://github.com/UCSD/campus-mobile/pull/' + prNumber + '">' + prNumber + '</a></td></tr>'
		} else {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Commit:</b></td><td><a href="https://github.com/UCSD/campus-mobile/commit/' + commitHash + '">' + commitHash + '</a></td></tr>'
		}
		if (buildIpaUrl) {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>IPA:</b></td><td><a href="' + buildIpaUrl + '" download>' + buildIpaFile + '</a></td></tr>'
		}
		if (buildApkUrl) {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>APK:</b></td><td><a href="' + buildApkUrl + '" download>' + buildApkFile + '</a></td></tr>'
		}
		teamsMessage += '<tr><td align="right"><b>Time:</b></td><td width="260">' + buildTimestamp + '</td></tr>'
		teamsMessage += '</table>'
		if (buildApkUrl) {
			teamsMessage += '<a href="' + buildApkUrl + '" download><img src="https://mobile.ucsd.edu/_images/apk-download.png" width="172" height="76"></a>'
		}

		console.log('\nCampusMobileBuilds: Sending Teams notification for v' + appVersion + ' (' + buildNumber + ')\n')

		// Send message via Teams webhook integration
		const abortTimeout = setTimeout(() => { controller.abort() }, timeout)
		const resp = await fetch(webhookUrl, {
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

try {
	if (appVersion && buildNumber && buildEnv && webhookUrl && fciArtifactLinks && buildBranch) {
		buildNotify(appVersion, buildNumber, buildEnv, webhookUrl, fciArtifactLinks, buildBranch, prNumber)
	} else {
		throw 'Error: Environment setup failed. Sample usage: node build_notifier 7.2 870 QA'
	}
} catch (err) {
	console.log('⚠ ERROR: Environment setup failed ⚠')
	console.log(err)
	process.exitCode = 1
}
