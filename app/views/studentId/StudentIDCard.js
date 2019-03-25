import React, { Component } from 'react'
import { Text } from 'react-native'
import { connect } from 'react-redux'
import Card from '../common/Card'
import css from '../../styles/css'

class StudentIDCard extends Component {
	constructor(props) {
		super()
	}

	render() {
		return (
			<Card id="studentId" title="Student ID">
				<Text style={{margin:100}}>
					Student ID Card
				</Text>
			</Card>
		)
	}
}


const mapStateToProps = state => ({

})

export default connect(mapStateToProps)(StudentIDCard)
