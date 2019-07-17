import React from 'react'
import { Text, View, StyleSheet } from 'react-native'

const forge = require('node-forge')

export default class node_forge_test extends React.Component {
	render() {
		/* setup component for test here */
		const { pki } = forge
		const ucsdPublicKey = '-----BEGIN PUBLIC KEY-----\n'
			+ 'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJD70ejMwsmes6ckmxkNFgKley\n'
			+ 'gfN/OmwwPSZcpB/f5IdTUy2gzPxZ/iugsToE+yQ+ob4evmFWhtRjNUXY+lkKUXdi\n'
			+ 'hqGFS5sSnu19JYhIxeYj3tGyf0Ms+I0lu/MdRLuTMdBRbCkD3kTJmTqACq+MzQ9G\n'
			+ 'CaCUGqS6FN1nNKARGwIDAQAB\n'
			+ '-----END PUBLIC KEY-----'

		const pk = pki.publicKeyFromPem(ucsdPublicKey)
		return (
			<View style={css.dependency_output}>
				{/* test component here*/}
				<Text>{pk.encrypt('test', 'RSA-OAEP')}</Text>
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
