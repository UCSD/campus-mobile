import React from 'react';

import { Actions } from 'react-native-router-flux';

import DataItem from '../common/DataItem';

const NewsItem = ({ data, card }) => (
	<DataItem
		data={data}
		card={card}
		onPress={() => Actions.NewsDetail({ data })}
	/>
);
/*
const NewsItem = ({ data }) => (
	<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => Actions.NewsDetail({ data })}>
		<View style={css.events_list_row}>
			<Text
				style={css.events_list_title}
				numberOfLines={1}
			>
				{data.title}
			</Text>

			<View style={css.events_list_info}>
				<View style={css.events_list_info_left}>
				
					{data.description ? (
						<Text
							style={css.events_list_desc}
							numberOfLines={3}
						>
							{data.description.trim()}
							}
						</Text>
					) : null }
					<Text style={css.events_list_postdate}>{moment(data.date).format('MMM Do, YYYY')}</Text>
				</View>

				{data.image ? (
					<Image style={css.events_list_image} source={{ uri: data.image }} />
				) : (
					<Image style={css.events_list_image} source={require('../../assets/img/MobileEvents_blank.jpg')} />
				)}
			</View>
		</View>
	</TouchableHighlight>
);
*/
export default NewsItem;
