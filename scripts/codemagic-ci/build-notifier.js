const fetch = require('node-fetch')
const AbortController = require('abort-controller')
const moment = require('moment')

const controller = new AbortController()
const INTERNAL_ERROR = { 'error': 'An error occurred.' }

const fciProjectId = process.argv[2]
const fciBuildId = process.argv[3]
const appVersion = process.argv[4]
const buildNumber = process.argv[5]
const buildEnv = process.argv[6]
const webhookUrl = process.argv[7]
const fciArtifactLinks = process.argv[8]
const buildBranch = process.argv[9]
const commitHash = process.argv[10]
const prNumber = process.argv[11]


const buildNotify = async (fciProjectId, fciBuildId, appVersion, buildNumber, buildEnv, webhookUrl, fciArtifactLinks, buildBranch, commitHash, prNumber = '') => {
	try {
		const buildTimestamp = moment().format('YYYY-MM-DD h:mm A')
		const timeout = 15000 // Abort request after 15 seconds
		const fciProjectLink = 'https://codemagic.io/app/' + fciProjectId + '/build/' + fciBuildId
		let buildApkUrl = ''
		let buildApkFile = ''
		let buildIpaUrl = ''
		let buildIpaFile = ''
		appVersion += '.' + buildNumber

		if (fciArtifactLinks) {
			fciArtifactLinks = JSON.parse(fciArtifactLinks)

			fciArtifactLinks.forEach((artifact, index) => {
				if (artifact.name === 'app-release.apk' && artifact.url) {
					buildApkUrl = artifact.url
					buildApkFile = artifact.name
				} else if (artifact.name === 'UC_San_Diego.ipa' && artifact.url) {
					buildIpaUrl = artifact.url
					buildIpaFile = artifact.name.replace('_', '&#95;')
				}
			})
		}

		// Construct build notifier message
		let teamsMessage = '#### Campus Mobile Build Notifier\n\n'
		teamsMessage += '<table border="0" style="margin:16px">'
		teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Version:</b></td><td>' + appVersion + '</td></tr>'
		teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Environment:</b></td><td>' + buildEnv + '</td></tr>'

		if (prNumber) {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>PR:</b></td><td><a href="https://github.com/UCSD/campus-mobile/pull/' + prNumber + '" style="text-decoration:underline">' + prNumber + '</a></td></tr>'
		} else {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Branch:</b></td><td><a href="https://github.com/UCSD/campus-mobile/tree/' + buildBranch + '" style="text-decoration:underline">' + buildBranch + '</a></td></tr>'
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Commit:</b></td><td><a href="https://github.com/UCSD/campus-mobile/commit/' + commitHash + '" style="text-decoration:underline">' + commitHash + '</a></td></tr>'
		}
		if (buildIpaUrl) {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>IPA:</b></td><td><a href="' + buildIpaUrl + '" download style="text-decoration:underline">' + buildIpaFile + '</a></td></tr>'
		}
		if (buildApkUrl) {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>APK:</b></td><td><a href="' + buildApkUrl + '" download style="text-decoration:underline">' + buildApkFile + '</a></td></tr>'
		}
		// Build failure
		if (fciArtifactLinks) {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Build:</b></td><td><span style="color:red">FAILED</span> (<a href="' + fciProjectLink + '" style="text-decoration:underline">detail</a>)</td></tr>'
		} else {
			teamsMessage += '<tr style="border-bottom: 1px solid grey"><td align="right"><b>Build:</b></td><td><span style="color:green">SUCCEEDED</span> (<a href="' + fciProjectLink + '" style="text-decoration:underline">detail</a>)</td></tr>'
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
	if (fciProjectId &&
		fciBuildId &&
		appVersion &&
		buildNumber &&
		buildEnv &&
		webhookUrl &&
		buildBranch &&
		commitHash) {
		buildNotify(
			fciProjectId,
			fciBuildId,
			appVersion,
			buildNumber,
			buildEnv,
			webhookUrl,
			fciArtifactLinks,
			buildBranch,
			commitHash,
			prNumber
		)
	} else {
		throw 'Error: Environment setup failed. Sample usage: node build_notifier 7.2 870 QA'
	}
} catch (err) {
	console.log('⚠ ERROR: Environment setup failed ⚠')
	console.log(err)
	process.exitCode = 1
}
