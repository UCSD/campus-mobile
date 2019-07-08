import React from 'react'
import {
	TouchableOpacity,
	View,
	Text,
	Switch,
	Animated,
	TouchableWithoutFeedback
} from 'react-native'
import { connect } from 'react-redux'
import css from '../../../styles/css'
import { getScreenWidth, getScreenHeight, deviceIphoneX } from '../../../util/general'

const WINDOW_WIDTH = getScreenWidth()
const WINDOW_HEIGHT = getScreenHeight()


class Filter extends React.Component {
	constructor(props) {
		super(props)

		this.filterOptions = ['Lower division', 'Upper division', 'Graduate division']
		this.onToggleSwitch = this.onToggleSwitch.bind(this)
		this.onClearPressed = this.onClearPressed.bind(this)
	}

	onToggleSwitch = (val, index) => {
		const filterVal = [...this.props.filterVal.filterVal]
		filterVal[index] = val
		this.props.updateFilter({
			filterVal
		})
	}

	onClearPressed = () => {
		this.props.updateFilter({
			filterVal: [false, false, false]
		})
	}


	render() {
		const { filterVal } = this.props.filterVal

		const {
			filterViewStyle,
			filterTitle,
			lineSeparator,
			optionStyle,
			clearStyle
		} = styles

		const {
			webreg_dropdown_background,
			webreg_dropdown_cancelTrigger,
			webreg_dropdown_overlay,
		} = css

		return (
			<View style={[webreg_dropdown_background, {  height: WINDOW_HEIGHT, width: WINDOW_WIDTH }]}>
				<TouchableWithoutFeedback
					onPress={() => this.props.showFilter(false)}
					style={webreg_dropdown_cancelTrigger}
				>
					<View style={[webreg_dropdown_overlay, { height: WINDOW_HEIGHT, width: WINDOW_WIDTH }]} />
				</TouchableWithoutFeedback>
				<Animated.View style={[filterViewStyle, this.props.style]}>
					<Text style={filterTitle}>Filter</Text>
					<Text style={{ fontSize: 12, lineHeight: 14, color: ' rgba(0, 0, 0, 0.5)', marginTop: 20, alignSelf: 'flex-start' }}>Show Only:</Text>
					<View>
						{this.filterOptions.map((option, index) => (
							<View style={{ paddingLeft: 22, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
								<Text style={optionStyle}>{option}</Text>
								<Switch
									trackColor={{ true: '#006A96', false: 'white' }}
									value={filterVal[index]}
									onValueChange={val => this.onToggleSwitch(val, index)}
									style={{
										transform: [{ scaleX: 0.5 }, { scaleY: 0.5 }]
									}}
								/>
							</View>
						))}
					</View>
					<View style={lineSeparator} />
					<TouchableOpacity onPress={this.onClearPressed} >
						<Text style={clearStyle}>Clear</Text>
					</TouchableOpacity>
				</Animated.View>
			</View>
		)
	}
}

const styles = {
	filterViewStyle: {
		width: 200,
		height: 210,
		borderTopLeftRadius: 10,
		borderBottomLeftRadius: 10,
		position: 'absolute',
		top: deviceIphoneX() ? 76 : 55,
		right: 0,
		flexDirection: 'column',
		alignItems: 'center',
		paddingHorizontal: 12,
		backgroundColor: '#fff',
		shadowColor: '#000',
		shadowOffset: {
			width: 0,
			height: 1,
		},
		shadowOpacity: 0.1,
		shadowRadius: 2,
	},
	filterTitle: {
		fontSize: 18,
		lineHeight: 21,
		fontWeight: 'bold',
		top: 12
	},
	optionStyle: {
		fontSize: 12,
		lineHeight: 14,
	},
	lineSeparator: {
		borderWidth: 0.5,
		width: 200 - 20,
		height: 0.5,
		marginVertical: 13,
		borderColor: 'rgba(0, 0, 0, 0.1)'
	},
	clearStyle: {
		fontSize: 18,
		lineHeight: 20,
		color: '#034263',
		textAlign: 'center'
	}
}

const mapDispatchToProps = dispatch => (
	{
		updateFilter: (filterVal) => {
			dispatch({
				type: 'UPDATE_FILTER',
				filterVal
			})
		},
		showFilter: (showFilter) => {
			dispatch({ type: 'CHANGE_FILTER_VISIBILITY', showFilter })
		},
	}
)

const mapStateToProps = state => ({
	filterVal: state.course.filterVal
})

export default connect(mapStateToProps, mapDispatchToProps)(Filter)
