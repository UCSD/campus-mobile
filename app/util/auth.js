import * as Keychain from 'react-native-keychain'

const forge = require('node-forge')

const { pki } = forge
const accessTokenSiteName = 'https://ucsd.edu'

/**
 * A module containing auth helper functions
 * @module auth
 */
module.exports = {
	/**
	 * Encrypts input using a public key
	 * @param {String} string String to encrypt
	 * @returns {String} Encrypted string
	 */
	encryptStringWithKey(string) {
		const publicKey = pki.publicKeyFromPem(this.ucsdPublicKey)
		const encrypted = publicKey.encrypt(string, 'RSA-OAEP')
		return forge.util.encode64(encrypted)
	},

	/**
	 * Encrypts / encodes input using base64
	 * @param {String} string String to encrypt
	 * @returns {String} Encrypted string
	 */
	encryptStringWithBase64(string) {
		return forge.util.encode64(string)
	},

	/**
	 * Stores user credentials in the keychain
	 * @param {String} user User's username
	 * @param {String} pass User's password
	 * @returns {boolean} True if keychain was stored
	 */
	storeUserCreds(user, pass) {
		return Keychain
			.setGenericPassword(user, pass)
			.then(() => (true))
	},

	/**
	 * Retrieves user credentials in the keychain
	 * @returns {Object} Object containing username and password
	 * or an error if something went wrong
	 */
	retrieveUserCreds() {
		return Keychain
			.getGenericPassword()
			.then(credentials => (credentials))
			.catch(error => (error));
	},

	/**
	 * Deletes user credentials in the keychain
	 * @returns {boolean} True once keychain is reset
	 */
	destroyUserCreds() {
		return Keychain
			.resetGenericPassword()
			.then(() => (true))
	},

	/**
	 * Stores access token in the keychain
	 * @param {String} token Access token to store
	 * @returns {boolean} True if keychain was stored
	 */
	storeAccessToken(token) {
		return Keychain
			.setInternetCredentials(accessTokenSiteName, 'accessToken', token)
			.then(() => (true))
	},

	/**
	 * Retrieves access token in the keychain
	 * @returns {Object} Object containing access token
	 * or an error if something went wrong
	 */
	retrieveAccessToken() {
		return Keychain
			.getInternetCredentials(accessTokenSiteName)
			.then(credentials => (credentials.password))
			.catch(error => (error))
	},

	/**
	 * Deletes access token in the keychain
	 * @returns {boolean} True once keychain is reset
	 */
	destroyAccessToken() {
		return Keychain
			.resetInternetCredentials(accessTokenSiteName)
			.then(() => (true))
	},

	/**
	 * Makes an authorized request using the access token.
	 * If the response is a 401 Unauthorized, return error
	 * indicating that access token has expired.
	 * @param {String} endpoint URL of API endpoint
	 * @returns {Object} Data from server
	 * or returns an error if HTTP resonse isn't 200
	 */
	authorizedFetch(endpoint) {
		return Keychain
			.getInternetCredentials(accessTokenSiteName)
			.then(credentials => (credentials.password))
			.then(accessToken => (
				fetch(endpoint, {
					headers: { 'Authorization': `Bearer ${accessToken}` }
				})
					.then((response) => {
						if (response.status === 200) return response.json()
						else {
							switch (response.status) {
								case 401: {
									const e = new Error('Expired access token')
									throw e
								}
								default: {
									const e = new Error(response.statusText)
									throw e
								}
							}
						}
					})
			))
			.catch((error) => {
				throw error
			})
	},

	ucsdPublicKey: '-----BEGIN PUBLIC KEY-----\n' +
		'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJD70ejMwsmes6ckmxkNFgKley\n' +
		'gfN/OmwwPSZcpB/f5IdTUy2gzPxZ/iugsToE+yQ+ob4evmFWhtRjNUXY+lkKUXdi\n' +
		'hqGFS5sSnu19JYhIxeYj3tGyf0Ms+I0lu/MdRLuTMdBRbCkD3kTJmTqACq+MzQ9G\n' +
		'CaCUGqS6FN1nNKARGwIDAQAB\n' +
		'-----END PUBLIC KEY-----'
};
