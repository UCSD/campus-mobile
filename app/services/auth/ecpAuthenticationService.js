import AppSettings from '../AppSettings';
import fs from 'fs';
import Orchestrator from 'orchestrator';
import crypto  from 'crypto';
import path from 'path';
import querystring from 'querystring';
import xmlformatter from 'xml-formatter';
import xpath from 'xpath';

const orchestrator = new Orchestrator(),
const xpathSelect = xpath.useNamespaces({
	"saml2p":"urn:oasis:names:tc:SAML:2.0:protocol",
	"paos":"urn:liberty:paos:2003-08",
	"ecp":"urn:oasis:names:tc:SAML:2.0:profiles:SSO:ecp",
})
const xmldom = require('xmldom')
const domParser = new xmldom.DOMParser()
const xmlSerializer = new xmldom.XMLSerializer()

/**
 *  ECP Authentication Provider
 *	This class authenticates a user resulting in an access token.
 */
class ECPAuthentication {
	getAccessToken = (accessTokenCallback) => {
		/**
		 *  Make an initial request to ECP for an access token
		 */
		orchestrator.add('ecp_request-access-token', async function() {
			var resp = await fetchWithLogging('Request access token from ECP', SSO.ECP_TOKEN_URL, SSO.ECP_FETCH_OPTIONS)
			var responseText = await resp.text()
			
			if (!resp.ok) {
				throw new Error('Invalid response from ECP [' + SSO.ECP_TOKEN_URL + ']')
			}
			
			SSO.ECP_INIT_RESPONSE = responseText
			SSO.ECP_INIT_RELAY_STATE = null
			SSO.ECP_INIT_IDP_PACKAGE = responseText
			let doc = domParser.parseFromString(responseText)
			SSO.ECP_INIT_RESPONSE_CONSUMER_URL = xpathSelect("//paos:Request/@responseConsumerURL", doc, true).value
			
			logger('Response Consumer URL: ' + SSO.ECP_INIT_RESPONSE_CONSUMER_URL)
			logger('Relay State: ' + SSO.ECP_INIT_RELAY_STATE)
		})

		/**
		 *  Post the crafted response to IdP
		 */
		orchestrator.add('idp_post-crafted-response', ['ecp_request-access-token'], async function() {

			var encodedAuth = encodeBase64(SSO.USER.PID + ':' + SSO.USER.PAC)
			var encryptedPAC = encryptWithRsaPublicKey(SSO.USER.PAC, './public_key.txt')
			var encodedAuthWithEncryptedPAC = encodeBase64(SSO.USER.PID + ':' + encryptedPAC)

			var IDP_FETCH_OPTIONS = {
				method: 'POST',
				body: SSO.ECP_INIT_IDP_PACKAGE,
				headers: {
					'Content-Type': 'text/xml; charset=utf-8',
					'Authorization': 'Basic ' + (SSO.PAC_ENCRYPTION_ENABLED ? encodedAuthWithEncryptedPAC : encodedAuth)
				}
			}

			var resp = await fetchWithLogging('Post crafted response to IdP', SSO.IDP_URL, IDP_FETCH_OPTIONS)
			var responseText = await resp.text()
			
			if (!resp.ok) {
				throw new Error('Invalid response from IdP [' + SSO.IDP_URL + ']')
			}

			const doc = domParser.parseFromString(responseText)
			
			const SAMLstatusCode = xpathSelect("//saml2p:Status/saml2p:StatusCode/@Value", doc, true).value
			
			if (SAMLstatusCode != "urn:oasis:names:tc:SAML:2.0:status:Success") {
				logger("SAML STATUS: " + xpathSelect("//saml2p:Status", doc, true))
				throw new Error('IDP returned status was not success')
			}
			

			SSO.IDP_SAML_ASSERTION = responseText
			SSO.IDP_ASSERTION_CONSUMER_SERVICE_URL = xpathSelect("//ecp:Response/@AssertionConsumerServiceURL", doc, true).value
			
			if (SSO.ECP_INIT_RESPONSE_CONSUMER_URL !== SSO.IDP_ASSERTION_CONSUMER_SERVICE_URL) {
				throw new Error(`ACS URL returned by SP (${SSO.ECP_INIT_RESPONSE_CONSUMER_URL}) does not match the one returned by the IDP (${SSO.IDP_ASSERTION_CONSUMER_SERVICE_URL})`)
			}
			
		})

		/**
		 *  Post the SAML assertion to SP to obtain access cookie
		 */
		orchestrator.add('ecp_post-saml-assertion', ['idp_post-crafted-response'], async function() {
			var resp = await fetchWithLogging('Post SAML assertion to SP', SSO.IDP_ASSERTION_CONSUMER_SERVICE_URL, {
				method: 'POST',
				redirect: 'manual',
				body: SSO.IDP_SAML_ASSERTION,
				headers: {
					'Content-Type': 'application/vnd.paos+xml',
				}
			})

			if (resp.status != 302) {
				throw new Error(`Invalid response when posting SAML assertion to SP.  Expected 302, got ${resp.status}`)
			}
			
			// As a result of this call, a session has been established via cookies, subsequent request will be "logged in"
		})

		/**
		 *  Re-request access token from ECP with SAML assertion cookie
		 */
		orchestrator.add('ecp_rerequest-access-token', ['ecp_post-saml-assertion'], async function() {
			var resp = await fetchWithLogging('Re-request access token from ECP', SSO.ECP_TOKEN_URL, SSO.ECP_FETCH_OPTIONS)

			if (!resp.ok) {
				throw new Error(`Invalid Response when re-requesting access token from ECP.  Expected 200, got ${resp.status}`)
			}

			var responseJson = await resp.json()

			logger(`ACCESS TOKEN is ${responseJson.access_token}`)
		})


		/**
		 * Orchestrator listeners
		 */
		// task_start: Orchestrator task was started
		orchestrator.on('task_start', function (event) {
			logger('\n###################################################################')
			logger('## Orchestrator: ' + event.message + '\n')
		})

		// task_stop: Orchestrator task completed successfully
		orchestrator.on('task_stop', function (event) {
			logger('\n## Orchestrator: ' + event.task + ' completed successfully')
			logger('###################################################################')
		})

		// stop: Orchestrator queue finished successfully
		orchestrator.on('stop', function (event) {
			logger('\n###################################################################')
			logger('## Orchestrator: All tasks completed successfully                ##')
			logger('###################################################################\n')
		})

		// err: Orchestrator queue was aborted due to a task error
		orchestrator.on('err', function (event) {
			logger('\n\n *** Error: Orchestrator: ' + event.message + '('+event.err +')' + ' *** \n')
		})


		/**
		 * Misc functions
		 */
		var logger = function(msg) {
			console.log(msg)
		}

		var encodeBase64 = function(str) {
			var buffer = new Buffer(str)
			return (buffer.toString('base64'))
		}

		var encryptWithRsaPublicKey = function(toEncrypt, publicKeyPath) {
			var publicKey = fs.readFileSync(path.resolve(publicKeyPath), 'utf8')
			var buffer = new Buffer(toEncrypt)
			var encrypted = crypto.publicEncrypt(publicKey, buffer)
			return encrypted.toString('base64')
		}

		/**
		 *  Fetch an endpoint, output request and response
		 */
		async function fetchWithLogging(msg, url, options) {
			logger(msg)
			logger(`URL: ${url}`)
			logger("OPTIONS:")
			logger(options)
			
			var resp = await fetch(url, options)
			
			logger("Request Complete.")
			logger(`STATUS_CODE: ${resp.statusText} (${resp.status})`)
			
			// Wrap the text and json functions, to log their payload when accessed.
			resp.orig_text = resp.text
			resp.text = async function () {
				var responseText = await resp.orig_text()
				logger("TEXT PAYLOAD:")
				if (resp.headers.get('content-type').includes('xml')) {
					logger(xmlformatter(responseText))
				} else {
					logger(responseText)
				}
				return responseText
			}
			
			resp.orig_json = resp.json
			resp.json = async function () {
				var responseJson = await resp.orig_json()
				logger("JSON PAYLOAD:")
				logger(responseJson)
				return responseJson
			}

			return resp
		}

		/**
		 * Start the orchestrator
		 */
		orchestrator.start('ecp_rerequest-access-token')
	}
}

export default function getECPAuthenticationService() {
	return new ECPAuthentication();
}
