import React from 'react'
import { View, StyleSheet } from 'react-native'

const EmptyItem = () => (
	<View style={styles.emptyRow} />
)

const styles = StyleSheet.create({
	emptyRow: { width: 75, flexDirection: 'row' },
})

export default EmptyItem
