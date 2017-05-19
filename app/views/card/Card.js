import React from 'react';
import { StyleSheet } from 'react-native';
import { connect } from 'react-redux';
import ElevatedView from 'react-native-elevated-view';

import { hideCard } from '../../actions/cards'; // TODO: Use saga
import {
	COLOR_LGREY
} from '../../styles/ColorConstants';
import CardHeader from './CardHeader';
import CardMenu from './CardMenu';

const Card = ({ hideMenu, cardRefresh, id, title, header, hide, children }) => (
	<ElevatedView
		style={styles.mainContainer}
		ref={(i) => { this._card = i; }}
		elevation={3}
	>
		{(title || header) ? (
			<CardHeader
				id={id}
				title={title}
				menu={
					<CardMenu
						hideMenu={hideMenu}
						cardRefresh={cardRefresh}
						hideCard={hide}
						id={id}
					/>
				}
				image={header}
			/>
		) : (null)}
		{children}
	</ElevatedView>
);

const mapDispatchToProps = (dispatch) => (
	{
		hide: (id) => {
			dispatch(hideCard(id));
		}
	}
);

const styles = StyleSheet.create({
	mainContainer: { backgroundColor: COLOR_LGREY, margin: 6, alignItems: 'flex-start', justifyContent: 'center' },
});

export default connect(null, mapDispatchToProps)(Card);
