import React from 'react'
import { TouchableOpacity, View, Text, TextInput, Dimensions } from 'react-native'
import Icon from 'react-native-vector-icons/SimpleLineIcons'
import MIcon from 'react-native-vector-icons/MaterialIcons'
import FIcon from 'react-native-vector-icons/FontAwesome'
import { connect } from 'react-redux'



const { width, height} = Dimensions.get('window')

class SearchHeader extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			input: '',
			searchedCourse: '',
			showFilter: false,
			optionVal: [false, true, false],
		}

		this.filterOptions = ['Lower division', 'Upper division', 'Graduate division']

		this.onChangeText = this.onChangeText.bind(this)
		this.onSubmit = this.onSubmit.bind(this)
		this.onFilterPressed = this.onFilterPressed.bind(this)
		this.onBackBtnPressed = this.onBackBtnPressed.bind(this)
	}

 	onChangeText = (text) => {
		this.setState({ input: text })
	}

	onSubmit = () => {
		const { input } = this.state
		this.setState({
			searchedCourse: input
		})
		this.props.updateInput(input)
	}

	onFilterPressed = () => {
		const { showFilter } = this.state
		this.setState({
			showFilter: !showFilter
		})
		this.props.showFilter(!showFilter)
	}

	onBackBtnPressed = () => {
		const { onPress } = this.props
		onPress()
		this.setState({
			searchedCourse:'',
			showFilter: false
		})
		this.props.updateInput('')
		this.props.showFilter(false)
	}

	renderBackBtn() {
		const { backBtnStyle } = styles

		return (
			<TouchableOpacity
				style={backBtnStyle}
				onPress={this.onBackBtnPressed}
			>
				<Icon name="arrow-left" size={20} />
			</TouchableOpacity>
		)
	}

	renderBar = () => {
		const { input } = this.state
		const { barViewStyle, inputStyle, termTextStyle, switcherContainerStyle } = styles
		const { selectedTerm, getDropDownLayout, onSelectTerm } = this.props



		return (
			<View style={[barViewStyle]}>
				<Icon name="magnifier" size={18} />
				<TextInput
					style={inputStyle}
					value={input}
					onChangeText={this.onChangeText}
					autoCorrect={false}
					autoFocus={true}
					returnKeyType="go"
					onSubmitEditing={this.onSubmit}
				/>
				<TouchableOpacity
					activeOpacity={1}
					onPress={onSelectTerm}
					style={switcherContainerStyle}
					onLayout={(event) => {
						const { layout } = event.nativeEvent
						getDropDownLayout(45, layout.y, layout.width + 20)
					}}
				>
					<Text style={termTextStyle}>{selectedTerm.term_code}</Text>
					<MIcon name="unfold-more" size={18} />
				</TouchableOpacity>
			</View>
		)
	}

	renderFilterBtn = () => {
		const { filterBtnStyle } = styles

		return (
			<TouchableOpacity
				style={filterBtnStyle}
				onPress={this.onFilterPressed}
			>
				<FIcon name="sliders" size={24} />
			</TouchableOpacity>
		)
	}

	componentDidMount(){
		const { showFilter, searchInput } = this.state;
		if( !showFilter || searchInput.length != 0){
			this.setState({
				showFilter: false,
				searchInput: '',
			})
			this.props.showFilter(false);
			this.props.updateInput('')
		}
	}

	render() {
		const { searchBarStyle } = styles


		return (
			<View 
				style={[searchBarStyle, this.props.style]}
				>
				{this.renderBackBtn()}
				{this.renderBar()}
				{this.renderFilterBtn()}
			</View>
		)
	}
}

const styles = {
	switcherContainerStyle: {
		flexDirection: 'row'
	},
	searchBarStyle: {
		flexDirection: 'row',
		width: '100%',
		marginTop: 15,
		marginBottom: 15,
		justifyContent: 'center',
		alignItems: 'center',
		shadowColor: '#000',
		shadowOffset: {
			width: 0,
			height: 1,
		},
		shadowOpacity: 0.1,
		shadowRadius: 2,
	},
	termTextStyle: {
		color: '#7D7D7D',
		fontSize: 15
	},
	backBtnStyle: {
		flex: 0.14,
		justifyContent: 'center',
		alignItems: 'center'
	},
	barViewStyle: {
		flex: 0.72,
		flexDirection: 'row',
		alignItems: 'center',
		borderWidth: 1,
		borderColor: '#194160',
		borderRadius: 20,
		paddingLeft: 15,
		paddingRight: 10,
		paddingTop: 5,
		paddingBottom: 5,
		backgroundColor: '#F1F1F1'
	},
	inputStyle: {
		flex: 1,
		fontSize: 15,
		paddingLeft: 10,
		paddingRight: 10
	},
	filterBtnStyle: {
		flex: 0.14,
		justifyContent: 'center',
		alignItems: 'center',
		zIndex:1000,
	},
	lineSeparator: {
		borderWidth: 0.5,
		width: (width / 2) - 20,
		height: 0.5,
		marginVertical: 13,
		borderColor: 'rgba(0, 0, 0, 0.1)'
	},
	overlayStyle: {
		flex: 1,
		position: 'absolute',
		backgroundColor:'black',
		opacity:0.2,
	}
}

const mapDispatchToProps = dispatch => (
	{
		updateInput: (input) => {
			dispatch({ type: 'UPDATE_INPUT', input })
		},
		selectTerm: (selectedTerm) => {
			dispatch({ type: 'SET_SELECTED_TERM', selectedTerm })
		},
		showFilter: (showFilter) => {
			dispatch({ type: 'CHANGE_FILTER_VISIBILITY', showFilter })
		}
	}
)

const mapStateToProps = state => ({
	selectedTerm: state.schedule.selectedTerm,
	searchInput: state.course.searchInput,
	filterVisible: state.course.filterVisible
})

export default connect(mapStateToProps, mapDispatchToProps)(SearchHeader)
