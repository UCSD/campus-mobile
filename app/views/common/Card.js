import React from 'react'
import { View } from 'react-native'
import { connect } from 'react-redux'

import css from '../../styles/css'
import CardHeader from './CardHeader'
import CardMenu from './CardMenu'

const Card = ({
	hideMenu,
	hideHeader,
	cardRefresh,
	id,
	title,
	header,
	hide,
	children,
	style,
	extraActions
}) => (
	<View
		style={style || css.card_container}
		ref={(i) => { this._card = i }}
	>
		<CardHeader
			id={id}
			title={title}
			menu={
				<CardMenu
					id={id}
					cardRefresh={cardRefresh}
					hideMenu={hideMenu}
					hideCard={hide}
					extraActions={extraActions}
				/>
			}
			image={header}
			hideHeader={hideHeader}
		/>
		{children}
	</View>
)

const mapDispatchToProps = dispatch => ({
	hide: (id) => {
		dispatch({ type: 'UPDATE_CARD_STATE', id, state: false })
	}
})

export default connect(null, mapDispatchToProps)(Card)
