
import React from 'react'
import {
	View,
	ListView,
	Text,
	TouchableHighlight,
} from 'react-native';
import TopStoriesItem from './TopStoriesItem';
import TopStoriesListView from './TopStoriesListView';

var css = require('../../styles/css');

export default class TopStoriesList extends React.Component {

	constructor(props){
		super(props);

		this.state = {
			topStoriesRenderAllRows: false
		};

		this.datasource = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
	}

	_renderRow = (row, sectionID, rowID) => {
		return (
			<TopStoriesItem data={row} navigator={this.props.navigator}/>
		);
	}

	render() {
		var topStoriesData = [];
		if (this.state.topStoriesRenderAllRows){
			topStoriesData = this.props.data;
		} 
		else {
			topStoriesData = this.props.data.slice(0, this.props.defaultResults);
		}

		var topStoriesDatasource = this.datasource.cloneWithRows(topStoriesData);

		return (
			<View>
				<ListView
					dataSource={topStoriesDatasource}
					renderRow={this._renderRow}
					style={css.wf_listview} />
				<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoTopStoriesListView() }>
					<View style={css.events_more}>
						<Text style={css.events_more_label}>View More News</Text>
					</View>
				</TouchableHighlight>
			</View>
		);
	}

	gotoTopStoriesListView() {
		this.props.navigator.push({ id: 'TopStoriesListView', title: 'News', name: 'News', component: TopStoriesListView, data: this.props.data });
	}
}
