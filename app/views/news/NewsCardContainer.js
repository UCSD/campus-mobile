import React from 'react';

import { connect } from 'react-redux';
import moment from 'moment';

import DataListCard from '../common/DataListCard';
import logger from '../../util/logger';

const NewsCardContainer = ({ newsData }) => {
	logger.ga('Card Mounted: News');
	if (newsData) {
		newsData.forEach((element) => {
			element.subtext = moment(element.date).format('MMM Do, YYYY');
		});
	}

	return (
		<DataListCard
			id="news"
			title="News"
			data={newsData}
			item={'NewsItem'}
		/>
	);
};

const mapStateToProps = (state) => (
	{
		newsData: state.news.data,
	}
);

const ActualNewsCard = connect(
	mapStateToProps
)(NewsCardContainer);

export default ActualNewsCard;
