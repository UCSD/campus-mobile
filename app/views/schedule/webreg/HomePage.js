import { TouchableWithoutFeedback, View, Text, FlatList, Platform, Button, Dimensions, Alert, TouchableOpacity } from 'react-native'
import React from 'react'
import { SearchBar } from 'react-native-elements'
import Icon from 'react-native-vector-icons/SimpleLineIcons'

import { terms } from './TermMockData.json'
import DropDown from './DropDown'
import LAYOUT from '../../../styles/LayoutConstants'
import { deviceIphoneX, platformIOS } from '../../../util/general'
import ClassCalendar from './ClassCalendar'
import FinalCalendar from './FinalCalendar'
import auth from '../../../util/auth'

const WINDOW_WIDTH = Dimensions.get('window').width
const WINDOW_HEIGHT = Dimensions.get('window').height

let termNameArr = []
let termCodeArr = []

const INITIAL_NAME_ARR = []
const INITIAL_CODE_ARR = []

terms.forEach((element) => {
	termNameArr.push(element.term_name)
	termCodeArr.push(element.term_code)
	INITIAL_NAME_ARR.push(element.term_name)
	INITIAL_CODE_ARR.push(element.term_code)
})

class HomePage extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			search: '',
			term: 'Spring 2019',
			show: false,
			display_type: 'Calendar',
		}
		this.showAppTime = this.showAppTime.bind(this)
		this.selectTerm = this.selectTerm.bind(this)
		this.handleCancel = this.handleCancel.bind(this)
		this.handleSelect = this.handleSelect.bind(this)
	}

	// componentDidMount() {
	//   updatePosition(this.refs['TERM_SELECT']);
	// }
	//
	// _term(newTerm) {
	// this.setState({
	//     ...this.state,
	//     term: newTerm
	//   });
	// }

	updateSearch = (search) => {
		this.setState({ search })
	};

	showAppTime = () => {
		Alert.alert(
			'Your Appointment Time',
			'First Pass: \n Second Pass:',
			[
				{ text: 'OK', onPress: () => console.log('OK Pressed') },
			],
			{ cancelable: false },
		)
	}

	selectTerm() {
		this.setState({ show: true })
	}

	handleCancel = () => {
		this.setState({ show: false })
	}

	handleSelect = (choice) => {
		termNameArr = [...INITIAL_NAME_ARR]
		termCodeArr = [...INITIAL_CODE_ARR]
		const index = termNameArr.indexOf(choice)
		termNameArr.unshift(termNameArr.splice(index, 1)[0])
		termCodeArr.unshift(termCodeArr.splice(index, 1)[0])
		this.setState({ show: false, term: choice })
	}

	showSelector() {
		if (this.state.show) {
			return (
				<DropDown
					x={this.dropDownX}
					y={this.dropDownY}
					cardWidth={this.width}
					onCancel={this.handleCancel}
					onSelect={this.handleSelect}
					choices={termNameArr}
				/>
			)
		}
	}

	renderDisplayType() {
		// 0 - Android, 1 - iPhone, 2 - iPhone X
		let device = 0
		if (platformIOS()) {
			if (deviceIphoneX()) {
				device = 2
			} else {
				device = 1
			}
		}

		if (this.state.display_type === 'Calendar') {
			return <ClassCalendar device={device} />
		} else if (this.state.display_type === 'Finals') {
			return <FinalCalendar device={device} />
		} else {
			return null // TODO - Need List view here
		}
	}

	renderSwitchNavigator(options) {
		const { switchContainerStyle } = styles

		if (platformIOS()) {
			if (deviceIphoneX()) {
				return (
					<View style={[switchContainerStyle, { paddingBottom: 34 }]}>
						{options.map((opt, i) => this.renderButton(opt, i))}
					</View>
				)
			} else {
				return (
					<View style={switchContainerStyle}>
						{options.map((opt, i) => this.renderButton(opt, i))}
					</View>
				)
			}
		}
	}

	renderButton(value, index) {
		const { switchItemStyle, switchTextStyle, chosenItemStyle } = styles

		if (value === this.state.display_type) {
			return (
				<View style={switchItemStyle} key={index}>
					<TouchableOpacity disabled style={chosenItemStyle}>
						<Text style={[switchTextStyle, { color: '#034263' }]}>{value}</Text>
					</TouchableOpacity>
				</View>
			)
		}

		return (
			<View style={switchItemStyle} key={index}>
				<TouchableOpacity onPress={() => this.setState({ display_type: value })}>
					<Text style={switchTextStyle}>{value}</Text>
				</TouchableOpacity>
			</View>
		)
	}

	render() {
		const {
			termContainerStyle,
			termTextStyle,
			termSelectorContainerStyle,
			iconContainerStyle,
			searchBarStyle,
			searchBarContainerStyle,
			searchTextStyle
		} = styles

		const options = ['Calendar', 'List', 'Finals']

		return (
			<View style={{ backgroundColor: '#FDFDFD', flex: 1 }}>
				<View style={termSelectorContainerStyle}>
					<View style={[iconContainerStyle, { alignItems: 'flex-end', paddingTop: 1 }]}>
						<Icon name="info" onPress={this.showAppTime} size={18} />
					</View>
					<View
						style={termContainerStyle}
						onLayout={(event) => {
							const { layout } = event.nativeEvent
							this.width = layout.width + 50
							this.dropDownX = 45
							this.dropDownY = layout.y
						}}
					>
						<Text style={termTextStyle}>{this.state.term}</Text>
					</View>
					<View style={[iconContainerStyle, { alignItems: 'flex-start', paddingTop: 2 }]}>
						<Icon name="arrow-down" onPress={this.selectTerm} size={18} />
					</View>
				</View>
				<View style={searchBarContainerStyle}>
					<View style={searchBarStyle}>
						<Icon name="magnifier" size={18} />
						<Text style={searchTextStyle}> Search Course </Text>
					</View>
				</View>
				{/* <Button onPress={() => auth.retrieveAccessToken().then(credentials => console.log(credentials))} title="Get Access Token" />*/}
				{this.renderDisplayType()}
				{this.renderSwitchNavigator(options)}
				{this.showSelector()}
			</View>
		)
	}
}

const styles = {
	searchTextStyle: {
		color: '#7D7D7D',
		fontSize: 18,
		paddingLeft: 10
	},
	searchBarContainerStyle: {
		marginLeft: 15,
		marginRight: 15,
		marginTop: 5,
		marginBottom: 10
	},
	searchBarStyle: {
		backgroundColor: '#F1F1F1',
		borderRadius: 15,
		paddingLeft: 15,
		paddingTop: 5,
		paddingBottom: 5,
		paddingRight: 10,
		flexDirection: 'row',
		alignItems: 'center'
	},
	termContainerStyle: {
		flex: 1,
	},
	termTextStyle: {
		fontFamily: 'Helvetica Neue',
		fontSize: 18,
		alignSelf: 'center'
	},
	termSelectorContainerStyle: {
		flexDirection: 'row',
		marginTop: 20,
		marginBottom: 10,
		marginLeft: 50,
		marginRight: 50
	},
	iconContainerStyle: {
		justifyContent: 'center',
		width: 20,
		height: 20
	},
	switchContainerStyle: {
		paddingTop: 17,
		paddingBottom: 17,
		bottom: 0,
		position: 'absolute',
		flexDirection: 'row',
		backgroundColor: '#FDFDFD',
		flex: 1
	},
	switchItemStyle: {
		flex: 1 / 3,
		justifyContent: 'center',
		alignItems: 'center'
	},
	switchTextStyle: {
		color: '#7D7D7D',
		paddingTop: 1,
		paddingBottom: 1
	},
	chosenItemStyle: {
		 borderColor: '#034263',
		 borderBottomWidth: 1
	}
}

export default HomePage
