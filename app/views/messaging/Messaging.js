import React, { Component } from 'react'
import { View, Text, ScrollView, FlatList } from 'react-native'
import { connect } from 'react-redux'
import moment from 'moment'
import Icon from 'react-native-vector-icons/MaterialIcons'
import logger from '../../util/logger'
import css from '../../styles/css'

const checkData = (data) => {
	const cleanData = data.filter((item) => {
		const day = moment.unix(item.timestamp)
		if (day.isValid()) {
			return true
		}
		return false
	})
	cleanData.sort( ( left, right ) => moment.utc(left.timestamp).diff(moment.utc(right.timestamp)))
	return cleanData
}

export class Messaging extends Component {
	static navigationOptions = { title: 'Notifications' }

	constructor() {
		super()
		this.state = {
			dataSource: [
				{
					id: 'sampleId1',
					title: 'Test Message', // optional
					timestamp: 1533338011173,
					sender: 'example@ucsd.edu',
					message: 'Hello. This is a test message from some sender. I have a lot to say so this might take up a bit of space. Lorem ipsum etc whatever.',
					// data is optional
					data: {
						example: true,
						another: true,
						url: 'https://google.com',
						explanation: 'This can be any user supplied data'
					}
				},
				{
					id: 'sampleId2',
					title: 'Test Message', // optional
					timestamp: 1533338423173,
					sender: 'example@ucsd.edu',
					message: 'Hello. This is a test message from some sender. I have a lot to say so this might take up a bit of space. Lorem ipsum etc whatever.',
					// data is optional
					data: {
						example: true,
						another: true,
						url: 'https://google.com',
						explanation: 'This can be any user supplied data'
					}
				},
				{
					id: 'sampleId2',
					title: 'Test Message', // optional
					timestamp: 1533338011163,
					sender: 'example@ucsd.edu',
					message: 'Hello. This is a test message from some sender. I have a lot to say so this might take up a bit of space. Lorem ipsum etc whatever.',
					// data is optional
					data: {
						example: true,
						another: true,
						url: 'https://google.com',
						explanation: 'This can be any user supplied data'
					}
				},
				{
					id: 'sampleId2',
					title: 'Test Message', // optional
					timestamp: 'fjdkla34928j',
					sender: 'example@ucsd.edu',
					message: 'Hello. This is a test message from some sender. I have a lot to say so this might take up a bit of space. Lorem ipsum etc whatever.',
					// data is optional
					data: {
						example: true,
						another: true,
						url: 'https://google.com',
						explanation: ''
					}
				},
				{
					id: 'sampleId2',
					title: 'Test Message', // optional
					timestamp: 153333800003,
					sender: 'example@ucsd.edu',
					message: 'Hello. This is a test message from some sender. I have a lot to say so this might take up a bit of space. Lorem ipsum etc whatever.',
					// data is optional
					data: {
						example: true,
						another: true,
						url: 'https://google.com',
						explanation: 'This can be any user supplied data'
					}
				}
			]
		}
	}
	componentDidMount() {
		logger.ga('View Loaded: Messaging')
	}

	renderSeparator = ({ leadingItem }) => (
		<View
			style={{ height: 1, width: '100%', backgroundColor: '#D2D2D2' }}
		/>
	)

	renderItem = ({ item }) => {
		const day = moment.unix(item.timestamp)
		return (
			<View style={{ height: 110, width: '100%', flexDirection: 'row', justifyContent: 'flex-start' }}>
				<View style={{ justifyContent: 'center', alignItems: 'center', marginLeft: 10, marginRight: 20 }}>
					<Icon
						name="check-circle"
						size={30}
						style={{ color: '#21D383' }}
					/>
				</View>
				<View  style={{ flexDirection: 'column', justifyContent: 'center' }}>
					<Text style={{ color: '#D2D2D2' }}>{day.format('MMMM Do')}</Text>
					<Text style={{ color: '#D2D2D2' }}>{item.title}</Text>
					<Text style={{ color: '#D2D2D2' }}>{item.data.explanation}</Text>
				</View>
			</View>

		)
	}

	render() {
		const filteredData = checkData(this.state.dataSource)
		console.log(filteredData.length)
		return (
			<ScrollView style={css.scroll_default} contentContainerStyle={css.main_full}>
				<FlatList
					style={{ backgroundColor: '#F9F9F9' }}
					data={filteredData}
					renderItem={this.renderItem}
					keyExtractor={(item, index) => item.id}
					ItemSeparatorComponent={this.renderSeparator}
				/>

			</ScrollView>
		)
	}
}

const mapStateToProps = (state, props) => (
	{}
)

const mapDispatchToProps = (dispatch, ownProps) => (
	{}
)

export default connect(mapStateToProps, mapDispatchToProps)(Messaging)
