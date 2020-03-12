import React, { Component } from 'react'
import { connect } from 'react-redux'
import SortableList from 'react-native-sortable-list'
import CardPreferencesItem from './CardPreferencesItem'
import Card from '../../common/Card'
import css from '../../../styles/css'

// View for user to manage preferences, including which cards are visible
class CardPreferences extends Component {
	constructor(props) {
		super(props)
		this.state = { scrollEnabled: true }
	}

	componentWillMount() {
		this.setState({ cardObject: this.getCardObject(this.props.cardOrder, this.props.cards) })
	}

	componentWillReceiveProps(nextProps) {
		/*
		* Recreating the cardObject will cause a re-render.
		* Only do this when absolutely necessary.
		* (Only necessary if the actual number of card rows
		* to display has changed and the layout bounds have
		* to be readjusted.)
		*/
		const nextCardObject = this.getCardObject(nextProps.cardOrder, nextProps.cards)
		if (Object.keys(this.state.cardObject).length !==
			Object.keys(nextCardObject).length) {
			this.setState({ cardObject: nextCardObject })
		}
	}

	shouldComponentUpdate(nextProps, nextState) {
		if (this.props.cardOrder !== nextProps.cardOrder) {
			return true
		} else {
			return false
		}
	}

	setCardState = (id, state) => {
		this.props.setCardState(id, state)
		this.props.updateScroll() // reset homeview scroll
	}

	getCardObject = (cardOrder, cards) => {
		const cardObject = {}

		if (Array.isArray(cardOrder)) {
			cardOrder.forEach((cardKey) => {
				cardObject[cardKey] = {
					id: cards[cardKey].id,
					name: cards[cardKey].name
				}
			})
		}
		return cardObject
	}

	toggleScroll = () => {
		this.setState({ scrollEnabled: !this.state.scrollEnabled })
	}

	_handleRelease = (key) => {
		if (Array.isArray(this._order)) {
			let newIndex
			this._order.forEach((orderKey, index) => {
				if (orderKey === key) newIndex = index
			})
			this.props.reorderCard(key, newIndex)
			this.toggleScroll() // toggle parent scroll
		}
	}

	render() {
		return (
			<Card id="cards" title="Cards" hideHeader style={css.full_flex}>
				<SortableList
					style={css.full_flex}
					data={this.state.cardObject}
					order={this.props.cardOrder}
					renderRow={
						({ data, active, disabled }) => {
							// Notices card is to remain enabled until further notice
							if (data.name !== 'Notices') {
								return (
									<CardPreferencesItem
										data={data}
										active={active}
									/>
								)
							} else {
								return null
							}
						}
					}
					onActivateRow={key => this.toggleScroll()}
					onChangeOrder={(nextOrder) => { this._order = nextOrder }}
					onReleaseRow={key => this._handleRelease(key)}
				/>
			</Card>
		)
	}
}

function mapStateToProps(state, props) {
	return {
		cards: state.cards.cards,
		cardOrder: state.cards.cardOrder
	}
}

function mapDispatchtoProps(dispatch) {
	return {
		reorderCard: (id, newIndex) => {
			dispatch({ type: 'REORDER_CARD', id, newIndex })
		},
		updateScroll: () => {
			dispatch({ type: 'UPDATE_HOME_SCROLL', scrollY: 0 })
		}
	}
}

export default connect(mapStateToProps, mapDispatchtoProps)(CardPreferences)
