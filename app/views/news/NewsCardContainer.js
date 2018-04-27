import React from 'react';

import { connect } from 'react-redux';
import moment from 'moment';

import DataListCard from '../common/DataListCard';
import logger from '../../util/logger';

export const NewsCardContainer = ({ newsData }) => {
	logger.ga('Card Mounted: News');

	let data = null;
	if (Array.isArray(newsData)) {
		newsData.forEach((element) => {
			element.subtext = moment(element.date).format('MMM Do, YYYY');
		});
		data = newsData;
	}
	return (
		<DataListCard
			id="news"
			title="News"
			data={data}
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
