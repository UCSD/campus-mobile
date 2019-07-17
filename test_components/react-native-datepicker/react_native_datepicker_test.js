import React from 'react'
import { View, StyleSheet } from 'react-native'
import DatePicker from 'react-native-datepicker'

export default class react_native_datepicker_test extends React.Component {
	constructor(props) {
		super(props)
		this.state = { date: '2016-05-15' }
	}

	render() {
		const { date } = this.state
		return (
			<DatePicker
				style={{ width: 200 }}
				date={date}
				mode="date"
				placeholder="select date"
				format="YYYY-MM-DD"
				minDate="2016-05-01"
				maxDate="2016-06-01"
				confirmBtnText="Confirm"
				cancelBtnText="Cancel"
				customStyles={{
					dateIcon: {
						position: 'absolute',
						left: 0,
						top: 4,
						marginLeft: 0
					},
					dateInput: {
						marginLeft: 36
					}
				}}
				onDateChange={(date) => { this.setState({ date }) }}
			/>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
