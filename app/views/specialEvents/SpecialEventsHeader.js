import React from 'react'
import {
	View,
	Text,
	StyleSheet,
} from 'react-native'
import moment from 'moment'

const SpecialEventsHeader = ({ timestamp, rows }) => (
	<View style={styles.header}>
		{timestamp ? (
			<Text style={styles.headerText}>
				{rows ? (
					moment(Number(timestamp)).format('MMM D[\n]h:mm A')
				) : (
					moment(Number(timestamp)).format('h:mm A')
				)}
			</Text>
		) : null }
	</View>
)

const styles = StyleSheet.create({
	header: { justifyContent: 'flex-start', alignItems: 'center', width: 75 },
	headerText: { textAlign: 'center', alignSelf: 'stretch', fontSize: 12, marginTop: 7 },
})

export default SpecialEventsHeader
