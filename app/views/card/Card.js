import React from 'react';
import { StyleSheet } from 'react-native';
import { connect } from 'react-redux';
import ElevatedView from 'react-native-elevated-view';

import {
	COLOR_LGREY
} from '../../styles/ColorConstants';
import CardHeader from './CardHeader';
import CardMenu from './CardMenu';

const Card = ({ hideMenu, cardRefresh, id, title, header, children }) => (
	<ElevatedView
		style={styles.mainContainer}
		ref={(i) => { this._card = i; }}
		elevation={3}
	>
		{(this.props.title || this.props.header) ? (
			<CardHeader
				id={this.props.id}
				title={this.props.title}
				menu={
					<CardMenu
						hideMenu={hideMenu}
						cardRefresh={cardRefresh}
					/>
				}
				image={this.props.header}
			/>
		) : (null)}
		{this.props.children}
	</ElevatedView>
);

const styles = StyleSheet.create({
	mainContainer: { backgroundColor: COLOR_LGREY, margin: 6, alignItems: 'flex-start', justifyContent: 'center' },
});

export default connect()(Card);
