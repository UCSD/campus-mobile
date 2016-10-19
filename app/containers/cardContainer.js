
import React from 'react';
import {
	Component
} from 'react-native';
import { connect } from 'react-redux'

// Cards
import EventCard   from '../events/EventCard'
import NewsCard    from '../news/NewsCard';
import WeatherCard from '../weather/WeatherCard';
import ShuttleCard from '../shuttle/ShuttleCard';

var CardContainer = React.createClass({

	render: function() {
		return this.renderScene();
	},

	renderScene: function(route, navigator, index, navState) {
		return (
			<View>
					{ this.getCards(navigator) }
			</View>
		);
	},

	getCards: function(navigator) {
		var cards = [];

		if (this.props.cards['weather']) {
			cards.push(<WeatherCard navigator={navigator} key='weather' />);
		}
		if (this.props.cards['shuttle']) {
			cards.push(<ShuttleCard navigator={navigator} key='shuttle' />);
		}
		if (this.props.cards['events']) {
			cards.push(<EventCard navigator={navigator} key='events' />);
		}
		if (this.props.cards['news']) {
			cards.push(<NewsCard navigator={navigator} key='news' />);
		}

		return cards;
	},
});

function mapStateToProps(state, props) {
  return state.cards
}

export default connect(
  mapStateToProps
)(CardContainer)
