'use strict'

import React from 'react'
import {
	View,
	ListView,
	Text,
	TouchableHighlight,
} from 'react-native';

import Card from '../card/Card'
import CardComponent from '../card/CardComponent'
import NewsList from './NewsList';
import NewsService from '../../services/newsService';

var css = require('../../styles/css');
var logger = require('../../util/logger');
var Entities = require('html-entities').AllHtmlEntities;
var entities = new Entities();

export default class NewsCard extends CardComponent {

	constructor(props) {
		super(props);

		this.fetchErrorInterval =  15 * 1000;			// Retry every 15 seconds
		this.fetchErrorLimit = 3;
		this.fetchErrorCounter = 0;

		this.state = {
			newsData: [],
			newsRenderAllRows: false,
			newsDataLoaded: false,
			fetchErrorLimitReached: false,
			newsDefaultResults: 3
		}
	}

	componentDidMount() {
		this.refresh();
	}

	refresh() {
		NewsService.FetchNews()
		.then((responseData) => {
			for (var i = 0; responseData.items.length > i; i++) {

				// Perform this on the feed level when possible
				responseData.items[i].title = entities.decode(responseData.items[i].title);

				if (responseData.items[i].image) {
					var image_lg = responseData.items[i].image.replace(/-150\./,'.').replace(/_teaser\./,'.');
					if (image_lg.length > 10) {
						responseData.items[i].image_lg = image_lg;
					}
				}
			}
			this.setState({
				newsData: responseData.items,
				newsDataLoaded: true
			});
		})
		.catch((error) => {
			logger.error(error);
			if (this.fetchErrorLimit > this.fetchErrorCounter) {
				this.fetchErrorCounter++;
				logger.log('ERR: fetchNews: refreshing again in ' + this.fetchErrorInterval/1000 + ' sec');
				this.refreshTimer = setTimeout( () => { this.refresh() }, this.fetchErrorInterval);
			} else {
				logger.log('ERR: fetchNews: Limit exceeded - max limit:' + this.fetchErrorLimit);
				this.setState({ fetchErrorLimitReached: true });
			}
		})
		.done();
	}

	render() {
		return (
			<Card id='news' title='News'>
				<View style={css.events_list}>
					{this.state.newsDataLoaded ? (
						<NewsList data={this.state.newsData} defaultResults={this.state.newsDefaultResults} navigator={this.props.navigator} />
					) : null}

					{this.state.fetchErrorLimitReached ? (
						<View style={[css.flexcenter, css.pad40]}>
							<Text>There was a problem loading the news</Text>
						</View>
					) : null }
				</View>
			</Card>
		);
	}
}
