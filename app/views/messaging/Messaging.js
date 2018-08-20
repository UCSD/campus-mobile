import React, { Component } from 'react'
import { View, Text, ScrollView, Image, FlatList } from 'react-native'
import { connect } from 'react-redux'
import logger from '../../util/logger'
import css from '../../styles/css'
import moment from 'moment'
import Icon from 'react-native-vector-icons/MaterialIcons'

export class Messaging extends Component {
	static navigationOptions = { title: 'Notifications' }

	constructor(){
		super()
		this.state = {
				dataSource : [
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
						timestamp: 1533338241173,
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

	render() {
		const {
    headerContentStyle,
    thumbnailContainerStyle,
    headerTextStyle,
  } = styles;
	this.state.dataSource.sort(function(left, right){
		return moment.utc(left.timestamp).diff(moment.utc(right.timestamp))
	});
		return (
			<ScrollView style={css.scroll_default} contentContainerStyle={css.main_full}>
				<FlatList
					style={{backgroundColor: '#F9F9F9'}}
  				data={this.state.dataSource}
  				renderItem={this.renderItem}
					keyExtractor={(item, index) => item.id}
					ItemSeparatorComponent={this.renderSeparator}
				/>

			</ScrollView>
		)
	}

	renderSeparator = ({ leadingItem }) => {
		if (leadingItem.data.explanation.length == 0){
			return null
		}
		return (
			<View
				style={{ height: 1, width: '100%', backgroundColor: '#D2D2D2'}}>
			</View>
		)
	}

	renderItem = ({ item }) => {
		var day = moment.unix(item.timestamp)
		if(item.data.explanation.length == 0){
			return null
		}
		return (
			<View style={{ height: 110, width: '100%', flexDirection: 'row', justifyContent: 'flex-start'}}>
				<View style={{justifyContent: 'center', alignItems: 'center', marginLeft: 10, marginRight: 20}}>
					<Icon
						name="check-circle"
						size={30}
						style={{color: '#21D383'}}
						/>
				</View>
				<View  style={{flexDirection: 'column', justifyContent: 'center'}}>
					<Text style={{color: '#D2D2D2'}}>{day.format("MMMM Do")}</Text>
					<Text style={{color: '#D2D2D2'}}>{item.title}</Text>
					<Text style={{color: '#D2D2D2'}}>{item.data.explanation}</Text>
				</View>
			</View>

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

const styles = {
  headerContentStyle: {
    flexDirection: 'column',
    justifyContent: 'space-around'
  },
  headerTextStyle: {
    fontSize: 18
  },
  thumbnailContainerStyle: {
    justifyContent: 'center',
    alignItems: 'center',
    marginLeft: 10,
    marginRight: 10
  }
};

export default connect(mapStateToProps, mapDispatchToProps)(Messaging)
