import React from 'react'
import { View, FlatList, ActivityIndicator } from 'react-native'
import FAIcon from 'react-native-vector-icons/FontAwesome'
import { connect } from 'react-redux'
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
		if (this.props.scrollData.length ) {
			this._flatlist.scrollToOffset({ x: this.props.lastScroll, animated: false })
		}
	}

	setNativeProps(props) {
		this._card.setNativeProps(props)
	}

	countDots = (width, height) => {
		const numDots = this.props.scrollData.length
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
		if (this.props.scrollData.length > 0) {
			list = (
				<FlatList
					ref={(c) => { this._flatlist = c }}
					extraData={this.props.extraData}
					style={css.scrollcard_listStyle}
					onContentSizeChange={this.countDots}
					pagingEnabled
					horizontal
					showsHorizontalScrollIndicator={false}
					onScroll={this.handleScroll}
					scrollEventThrottle={0}
					data={this.props.scrollData}
					enableEmptySections={true}
					keyExtractor={(listItem, index) => {
						if (listItem.id) {
							// Return unique saved shuttle stop id
							return listItem.id.toString()
						} else if (listItem.LocationId) {
							// Return unique saved parking lot LocationId
							return listItem.LocationId
						} else {
							// Default return
							return index.toString()
						}
					}}
					renderItem={this.props.renderItem}
				/>
			)
		} else {
			list = (
				<View style={[css.dlc_cardcenter, css.dlc_wc_loading_height]}>
					<ActivityIndicator size="large" />
				</View>
			)
		}

		return (
			<View>
				<View
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
				</View>

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
