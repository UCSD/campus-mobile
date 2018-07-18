import React, { Component } from 'react'
import { Text, ScrollView } from 'react-native'
import { connect } from 'react-redux'
import logger from '../../util/logger'
import css from '../../styles/css'

export class Messaging extends Component {
	static navigationOptions = { title: 'Messaging' }

	componentDidMount() {
		logger.ga('View Loaded: Messaging')
	}

	render() {
		return (
			<ScrollView style={css.scroll_default} contentContainerStyle={css.main_full}>
				<Text>TODO: Implement messaging UI</Text>
			</ScrollView>
		)
	}
}

const mapStateToProps = (state, props) => (
	{

	}
)

const mapDispatchToProps = (dispatch, ownProps) => (
	{

	}
)

export default connect(mapStateToProps, mapDispatchToProps)(Messaging)
