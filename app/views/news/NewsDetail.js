import React from 'react';
import {
	View,
	Text,
	ScrollView,
	Image,
	Linking,
	TouchableHighlight,
	Dimensions,
} from 'react-native';

const windowSize = Dimensions.get('window');
const windowWidth = windowSize.width;

const css = require('../../styles/css');
const logger = require('../../util/logger');
const moment = require('moment');

class NewsDetail extends React.Component {

	constructor(props) {
		super(props);
		this.state = {
			validImage: true
		};
	}

	componentDidMount() {
		logger.ga('View Loaded: News Detail: ' + this.props.data.title);
	}

	render() {
		const data = this.props.data;

		return (
			<View style={[css.main_container, css.whitebg]}>
				<ScrollView contentContainerStyle={css.scroll_default}>

					{(data.image_lg && this.state.validImage) ? (
						<Image
							source={{ uri: data.image_lg }}
							style={{
								width: Dimensions.get('window').width,
								height: 200
							}}
							onError={() => this.setState({ validImage: false })}
							resizeMode={'contain'}
						/>
					) : null }

					<View style={css.news_detail_container}>
						<View style={css.eventdetail_top_right_container}>
							<Text style={css.eventdetail_eventname}>{data.title}</Text>
							<Text style={css.eventdetail_eventdate}>
								{moment(data.date).format('MMM Do, YYYY')}
							</Text>
						</View>

						<Text style={css.eventdetail_eventdescription}>{data.description}</Text>

						{data.link ? (
							<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => Linking.openURL(data.link)}>
								<View style={css.eventdetail_readmore_container}>
									<Text style={css.eventdetail_readmore_text}>Read the full article</Text>
								</View>
							</TouchableHighlight>
						) : null }

					</View>

				</ScrollView>
			</View>
		);
	}
};

export default NewsDetail;
