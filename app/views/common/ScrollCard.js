import React from 'react'
import { View, FlatList } from 'react-native'
import FAIcon from 'react-native-vector-icons/FontAwesome'
import { connect } from 'react-redux'
import ElevatedView from 'react-native-elevated-view'

import CardHeader from './CardHeader'
import CardMenu from './CardMenu'
import { trackException } from '../../util/logger'
import css from '../../styles/css'
import LAYOUT from '../../styles/LayoutConstants'

class ScrollCard extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			numDots: 0,
			dotIndex: 0
		}
	}

	componentDidMount() {
		this._flatlist.scrollToOffset({ x: this.props.lastScroll, animated: false })
	}

	setNativeProps(props) {
		this._card.setNativeProps(props)
	}

	countDots = (width, height) => {
		const numDots = Math.floor(width / LAYOUT.MAX_CARD_WIDTH)
		this.setState({ numDots })
	}

	handleScroll = (event) => {
		if (this.props.updateScroll) {
			this.props.updateScroll(event.nativeEvent.contentOffset.x)
		}
		const dotIndex = Math.floor(event.nativeEvent.contentOffset.x / (LAYOUT.MAX_CARD_WIDTH - 12)) // minus padding
		this.setState({ dotIndex })
	}

	render() {
		let list
		if (this.props.scrollData !== {}) {
			list = (
				<FlatList
					ref={(c) => { this._flatlist = c }}
					style={css.scrollcard_listStyle}
					onContentSizeChange={this.countDots}
					pagingEnabled
					horizontal
					showsHorizontalScrollIndicator={false}
					onScroll={this.handleScroll}
					scrollEventThrottle={0}
					data={this.props.scrollData}
					extraData={this.props.extraData}
					enableEmptySections={true}
					keyExtractor={(listItem, index) => {
						if (listItem.id) return listItem.id.toString() + index
						if (listItem.LocationId) return listItem.LocationId.toString() + index
						else {
							const error = new Error('Invalid ScrollCard list item')
							trackException(error, listItem)
							return index
						}
					}}
					renderItem={this.props.renderItem}
				/>
			)
		}

		return (
			<View>
				<ElevatedView
					elevation={3}
					style={[css.card_container, this.state.numDots <= 1 ? css.scrollcard_main_marginBottom : null]}
					ref={(i) => { this._card = i }}
				>
					<CardHeader
						id={this.props.id}
						title={this.props.title}
						menu={
							<CardMenu
								hideCard={this.props.hide}
								cardRefresh={this.props.cardRefresh}
								extraActions={this.props.extraActions}
								id={this.props.id}
							/>
						}
					/>
					{list}
					{this.props.actionButton}
				</ElevatedView>

				{ this.state.numDots > 1 ? (
					<PageIndicator
						numDots={this.state.numDots}
						dotIndex={this.state.dotIndex}
					/>
				) : null }
			</View>
		)
	}
}

const PageIndicator = ({ numDots, dotIndex }) => {
	const dots = []
	for (let i = 0; i < numDots; ++i) {
		const dotName = (dotIndex === i) ? ('circle') : ('circle-thin')
		const dot = (
			<FAIcon
				style={css.scrollcard_dotStyle}
				name={dotName}
				size={10}
				key={'dot' + i}
			/>
		)
		dots.push(dot)
	}

	return (
		<View style={css.scrollcard_dotsContainer}>
			{dots}
		</View>
	)
}

const mapDispatchToProps = dispatch => ({
	hide: (id) => {
		dispatch({ type: 'UPDATE_CARD_STATE', id, state: false })
	}
})

export default connect(null, mapDispatchToProps)(ScrollCard)
