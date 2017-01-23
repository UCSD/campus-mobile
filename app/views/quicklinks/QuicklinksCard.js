import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
} from 'react-native';

import { Actions } from 'react-native-router-flux';
import Card from '../card/Card';
import CardComponent from '../card/CardComponent';
import QuicklinksService from '../../services/quicklinksService';
import QuicklinksList from './QuicklinksList';
import QuicklinksListView from './QuicklinksListView';

const css = require('../../styles/css');
const logger = require('../../util/logger');

export default class QuicklinksCard extends CardComponent {

	constructor(props) {
		super(props);
		this.quicklinksCardMaxResults = 4;
		this.state = {
			quicklinksDataLoaded: false,
			quicklinksRenderAllRows: false,
		};
	}

	componentDidMount() {
		this.refresh(this.props.location);
	}

	render() {
		return (
			<Card title="Links">
				{this.state.quicklinksDataLoaded ? (
					<View style={css.quicklinks_card}>
						<View style={css.quicklinks_locations}>
							<QuicklinksList data={this.state.quicklinksData} navigator={this.props.navigator} limitResults={this.quicklinksCardMaxResults} />
						</View>
						<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoQuicklinksListView(this.state.quicklinksData) }>
							<View style={css.card_more}>
								<Text style={css.card_more_label}>View All</Text>
							</View>
						</TouchableHighlight>
					</View>
				) : null }
			</Card>
		);
	}

	refresh(location) {
		QuicklinksService.FetchQuicklinks()
		.then((responseData) => {
			this.setState({
				quicklinksData: responseData,
				quicklinksDataLoaded: true
			});
		})
		.catch((error) => {
			logger.log('ERR: QuicklinksService: ' + error)
		})
		.done();
	}

	gotoQuicklinksListView() {
		Actions.QuicklinksListView({ data: this.state.quicklinksData });
	}
}