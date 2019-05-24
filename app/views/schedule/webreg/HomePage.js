import { TouchableWithoutFeedback, View, Text, FlatList, Platform, Button, Dimensions, Alert } from 'react-native'
import React from 'react'
import { SearchBar } from 'react-native-elements'
import Icon from 'react-native-vector-icons/SimpleLineIcons'

import { terms } from './TermMockData.json'
import DropDown from './DropDown'
import LAYOUT from '../../../styles/LayoutConstants'
import { deviceIphoneX, platformIOS } from '../../../util/general'
import ClassCalendar from './ClassCalendar'
import FinalCalendar from './FinalCalendar'

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
			display_type: 'Calendar'
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
		termNameArr.unshift(termNameArr.splice(index, 1))
		termCodeArr.unshift(termCodeArr.splice(index, 1))
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
		if(this.state.display_type === 'Calendar') {
			return <ClassCalendar />
		} else if(this.state.display_type === 'Finals') {
			return <FinalCalendar />
		} else {
			return null // TODO - Need List view here
		}
	}

	renderSwitchNavigator() {
		if(platformIOS()) {
			if(deviceIphoneX()) {
				return (
					<View style={switchContainerStyle}>

					</View>
				)
			} else {
				return (
					<View style={switchContainerStyle}>
					</View>
				)
			}
		}
	}

	renderButton(value) {
		const { switchItemStyle, switchTextStyle } = styles
	}

	render() {
		const {
			termContainerStyle,
			termTextStyle,
			termSelectorContainerStyle,
			iconContainerStyle
		} = styles

		return (
			<View style={{ backgroundColor: '#F5F5F5', flex: 1 }}>
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
				<View style={{ marginLeft: 15, marginRight: 15 }}>
					<SearchBar ref={search => this.search = search} placeholder="Search Course" onChangeText={this.updateSearch} value={this.state.search} platform={Platform.OS} onCancel={() => console.log('hahaa')} autoCorrect={false} />
				</View>
				{this.renderSwitchNavigator()}
				{this.renderDisplayType()}
				{this.showSelector()}
			</View>
		)
	}
}

const styles = {
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
		position: 'absolute',
		flexDirection: 'row',
		flex: 1
	},
	switchItemStyle: {
		flex: 1/3,
		justifyContent: 'center',
		alignItems: 'center'
	},
	switchTextStyle: {
		color: '#7D7D7D'
	}
}

export default HomePage
