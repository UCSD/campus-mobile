import React from 'react';
import {
	AppState,
} from 'react-native';

import { connect } from 'react-redux';
import moment from 'moment';

import DataListCard from '../common/DataListCard';
import CardComponent from '../card/CardComponent';
import { updateNews } from '../../actions/news';
import logger from '../../util/logger';

class NewsCardContainer extends CardComponent {
	componentDidMount() {
		logger.ga('Card Mounted: News');

		this.props.updateNews();
		AppState.addEventListener('change', this._handleAppStateChange);
	}

	componentWillUnmount() {
		AppState.removeEventListener('change', this._handleAppStateChange);
	}

	_handleAppStateChange = (currentAppState) => {
		this.setState({ currentAppState });
		this.props.updateNews();
	}

	render() {
		const { newsData } = this.props;
		if (newsData) {
			newsData.forEach((element) => {
				element.subtext = moment(element.date).format('MMM Do, YYYY');
			});
		}

		return (
			<DataListCard
				title="News"
				data={newsData}
				item={'NewsItem'}
			/>
		);
	}
}

const mapStateToProps = (state) => (
	{
		newsData: state.news.data,
	}
);

const mapDispatchToProps = (dispatch) => (
	{
		updateNews: () => {
			dispatch(updateNews());
		}
	}
);

const ActualNewsCard = connect(
	mapStateToProps,
	mapDispatchToProps
)(NewsCardContainer);

export default ActualNewsCard;
