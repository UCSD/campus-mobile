import React from 'react'
import { connect } from 'react-redux'
import moment from 'moment'
import DataListCard from '../common/DataListCard'

export const NewsCardContainer = ({ newsData }) => {
	let data = null
	if (Array.isArray(newsData)) {
		const parsedNewsData = newsData.slice()
		parsedNewsData.forEach((element, index) => {
			parsedNewsData[index] = {
				...element,
				subtext: moment(element.date).format('MMM Do, YYYY')
			}
		})
		data = parsedNewsData
	}
	return (
		<DataListCard
			id="news"
			title="News"
			data={data}
			item="NewsItem"
		/>
	)
}

const mapStateToProps = state => (
	{ newsData: state.news.data }
)

const ActualNewsCard = connect(mapStateToProps)(NewsCardContainer)

export default ActualNewsCard
