import React from 'react'
import { ScrollView } from 'react-native'
import { connect } from 'react-redux'
import logger from '../../util/logger'
import DiningDescription from './DiningDescription'
import DiningImages from './DiningImages'
import DiningDirections from './DiningDirections'
import DiningMenu from './DiningMenu'
import css from '../../styles/css'

class DiningDetail extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			filters: [],
			activeMeal: 'Breakfast',
		}
	}

	componentDidMount() {
		this.props.getMenuItems(this.props.navigation.state.params.data.id)
		logger.ga('View Mounted: Dining Detail')
	}

	shouldComponentUpdate(nextProps, nextState) {
		if (this.props.menuData !== nextProps.menuData) {
			return true
		}
		else if (
			this.state.filters !== nextState.filters
			|| this.state.activeMeal !== nextState.activeMeal
		) {
			return true
		}
		else if (
			this.props.menuRequestStatus !== nextProps.menuRequestStatus
		) {
			return true
		}
		else return false
	}

	addFilter = (filter) => {
		if (filter === 'Breakfast' || filter === 'Lunch' || filter === 'Dinner') {
			this.setState({ activeMeal: filter })
		} else {
			if (this.state.filters.indexOf(filter) < 0) {
				// Add filter
				this.setState({ filters: [...this.state.filters, filter] })
			} else {
				// Remove filter
				const temp = [...this.state.filters]
				temp.splice(temp.indexOf(filter), 1)
				this.setState({ filters: temp })
			}
		}
	}

	render() {
		const { menuData, navigation, menuRequestStatus } = this.props
		const { params } = navigation.state
		const { data } = params
		console.log(data)
		return (
			<ScrollView style={css.scroll_default} contentContainerStyle={css.main_full}>
				<DiningDescription
					name={data.name}
					description={data.description}
					regularHours={data.regularHours}
					specialHours={data.specialHours}
					paymentOptions={data.paymentOptions}
				/>
				{
					(data.images && data.images.length > 0) ? (
						<DiningImages
							images={data.images}
						/>
					) : (
						null
					)
				}
				{
					(data.coords) ? (
						<DiningDirections
							latitude={data.coords.lat}
							longitude={data.coords.lon}
							distance={data.distanceMilesStr}
						/>
					) : (
						(data.address) ? (
							<DiningDirections
								address={data.address}
							/>
						) : (null)
					)
				}
				<DiningMenu
					navigation={this.props.navigation}
					requestStatus={menuRequestStatus}
					data={menuData}
					menuUrl={data.menuUrl}
					filters={this.state.filters}
					activeMeal={this.state.activeMeal}
					addFilter={filter => this.addFilter(filter)}
				/>
			</ScrollView>
		)
	}
}

const mapStateToProps = (state, props) => (
	{
		menuData: state.dining.menus[state.dining.lookup[props.navigation.state.params.data.id]],
		menuRequestStatus: state.requestStatuses.GET_DINING_MENU,
		lookup: state.dining.lookup
	}
)

const mapDispatchToProps = dispatch => (
	{
		getMenuItems: (menuId) => {
			dispatch({ type: 'GET_DINING_MENU', menuId })
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(DiningDetail)
