import React from 'react'
import { connect } from 'react-redux'
import { View, Text, ActivityIndicator } from 'react-native'
import { withNavigation } from 'react-navigation'
import css from '../../styles/css'
import Card from '../common/Card'
import DiningListView  from './DiningListView'

class DiningCardContainer extends React.Component {
	constructor(props) {
		super()
	}
	render() {
		const {
			navigation,
			diningData,
			rows,
			updateDiningSort
		} = this.props

		const sortAlphaNumeric = () => {
			updateDiningSort('A-Z')
		}
		const sortDistance = () => {
			updateDiningSort('Closest')
		}
		const extraActions = [
			{
				name: 'A-Z',
				action: sortAlphaNumeric
			},
			{
				name: 'Closest',
				action: sortDistance
			}
		]
		return (
			<Card id="dining" title="Dining" extraActions={extraActions}>
				{ diningData ? (
					<View>
						<DiningListView
							data={diningData}
							rows={rows}
							scrollEnabled={false}
							style={css.DataList_card_list}
						/>
						<View style={css.card_button_container}>
							<Text
								style={css.card_button_text}
								onPress={() => navigation.navigate('DiningListViewAll')}
							>
								View All
							</Text>
						</View>
					</View>
				) : (
					<View style={[css.dlc_cardcenter, css.dlc_wc_loading_height]}>
						<ActivityIndicator size="large" />
					</View>
				)}
			</Card>
		)
	}
}

function mapStateToProps(state) {
	return {
		diningData: state.dining.data,
	}
}

const mapDispatchToProps = dispatch => (
	{
		updateDiningSort: (sortBy) => {
			dispatch({ type: 'SET_DINING_SORT', sortBy })
			dispatch({ type: 'REORDER_DINING' })
		}
	}
)

DiningCardContainer.defaultProps = {
	rows: 3
}

const ActualDiningCard = connect(mapStateToProps,mapDispatchToProps)(withNavigation(DiningCardContainer))
export default ActualDiningCard
