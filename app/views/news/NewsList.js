
import React from 'react'
import {
	View,
	ListView,
	Text,
	TouchableHighlight,
} from 'react-native';
import NewsItem from './NewsItem';
import NewsListView from './NewsListView';

var css = require('../../styles/css');
var logger = require('../../util/logger');

export default class NewsList extends React.Component {

	constructor(props){
		super(props);

		this.state = {
			newsRenderAllRows: false
		};

		this.datasource = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
	}

	componentDidMount() {
		logger.ga('View Loaded: NewsList' );
	}

	_renderRow = (row, sectionID, rowID) => {
		return (
			<NewsItem data={row} navigator={this.props.navigator}/>
		);
	}

	render() {
		var newsData = [];
		if (this.state.newsRenderAllRows){
			newsData = this.props.data;
		} 
		else {
			newsData = this.props.data.slice(0, this.props.defaultResults);
		}

		var newsDatasource = this.datasource.cloneWithRows(newsData);

		return (
			<View>
				<ListView
					dataSource={newsDatasource}
					renderRow={this._renderRow}
					style={css.wf_listview} />
				<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoNewsListView() }>
					<View style={css.events_more}>
						<Text style={css.events_more_label}>View All News</Text>
					</View>
				</TouchableHighlight>
			</View>
		);
	}

	gotoNewsListView() {
		this.props.navigator.push({ id: 'NewsListView', title: 'News', name: 'News', component: NewsListView, data: this.props.data });
	}
}
