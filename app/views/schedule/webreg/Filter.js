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
import { getScreenWidth, getScreenHeight } from '../../../util/general'
import COLOR from '../../../styles/ColorConstants'

const WINDOW_WIDTH = getScreenWidth()
const WINDOW_HEIGHT = getScreenHeight()


class Filter extends React.Component {
	constructor(props) {
		super(props)

		this.filterOptions = ['Hide lower division', 'Hide upper division', 'Hide graduate division']
		this.onToggleSwitch = this.onToggleSwitch.bind(this)
		this.onClearPressed = this.onClearPressed.bind(this)
	}

	onToggleSwitch = (val, index) => {
		const { filterVal } = this.props
		const currFilter = [...filterVal]
		currFilter[index] = val
		this.props.updateFilter(currFilter)
	}

	onClearPressed = () => {
		this.props.updateFilter([false, false, false])
	}

	render() {
		const { filterVal, onLayout } = this.props
		console.log(filterVal)
		const {
			filterViewStyle,
			optionContainerStyle,
			optionStyle,
			dragContainerStyle,
			dragStyle
		} = styles

		const {
			webreg_dropdown_background,
			webreg_dropdown_cancelTrigger,
			webreg_dropdown_overlay,
		} = css
		/**
		 * <View style={[webreg_dropdown_background, { height: WINDOW_HEIGHT, width: WINDOW_WIDTH }]}>
				<TouchableWithoutFeedback
					onPress={() => this.props.showFilter(false)}
					style={webreg_dropdown_cancelTrigger}
				>
					<View style={[webreg_dropdown_overlay, { height: WINDOW_HEIGHT, width: WINDOW_WIDTH }]} />
				</TouchableWithoutFeedback>
			</View>
		 */
		return (
			<Animated.View
				style={[filterViewStyle, this.props.style]}
				onLayout={event => (onLayout ? onLayout(event) : null)}
			>
				<View>
					{this.filterOptions.map((option, index) => (
						<View key={option} style={optionContainerStyle}>
							<Text style={optionStyle}>{option}</Text>
							<Switch
								trackColor={{ true: COLOR.GREEN, false: COLOR.WHITE }}
								value={filterVal ? filterVal[index] : false}
								onValueChange={val => this.onToggleSwitch(val, index)}
								style={{
									transform: [{ scaleX: 0.7 }, { scaleY: 0.7 }]
								}}
							/>
						</View>
					))}
				</View>
				<View style={dragContainerStyle}>
					<TouchableWithoutFeedback
						onPress={() => {}}
					>
						<View style={dragStyle} />
					</TouchableWithoutFeedback>
				</View>
			</Animated.View>
		)
	}
}

const styles = {
	dragContainerStyle: {
		marginTop: 10
	},
	dragStyle: {
		height: 10,
		width: 50,
		borderBottomWidth: 4,
		borderTopWidth: 4,
		borderColor: 'rgba(196, 196, 196, 0.5)'
	},
	optionContainerStyle: {
		flexDirection: 'row',
		justifyContent: 'space-between',
		alignItems: 'center',
		paddingHorizontal: 40,
		width: WINDOW_WIDTH
	},
	filterViewStyle: {
		flexDirection: 'column',
		alignItems: 'center',
		paddingVertical: 12,
		paddingTop: 10,
		paddingBottom: 10,
		backgroundColor: COLOR.PRIMARY,
	},
	optionStyle: {
		fontSize: 16,
		color: COLOR.WHITE
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
		showFilter: (filterVisible) => {
			dispatch({ type: 'CHANGE_FILTER_VISIBILITY', filterVisible })
		},
	}
)

const mapStateToProps = state => ({
	filterVal: state.webreg.filterVal
})

export default connect(mapStateToProps, mapDispatchToProps)(Filter)
