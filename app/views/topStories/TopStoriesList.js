
import React from 'react'
import {
	View,
  ListView,
	Text,
	TouchableHighlight,
} from 'react-native';
import TopStoriesItem from './TopStoriesItem';

var css = require('../../styles/css');

export default class TopStoriesList extends React.Component {

  constructor(props){
    super(props);

		this.state = {
			topStoriesRenderAllRows: false
		};

    this.datasource = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
  }

  render() {
    var topStoriesData = [];
    if (this.state.topStoriesRenderAllRows){
      topStoriesData = this.props.data;
    } else {
      topStoriesData = this.props.data.slice(0, 3);
    }

    var topStoriesDatasource = this.datasource.cloneWithRows(topStoriesData);

    return (
			<View>
	      <ListView
	        dataSource={topStoriesDatasource}
	        renderRow={ (row) => <TopStoriesItem data={row} navigator={this.props.navigator} /> }
	        style={css.wf_listview} />

	      {this.state.topStoriesRenderAllRows === false ? (
	        <TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.setState({topStoriesRenderAllRows: true}) }>
	          <View style={css.events_more}>
	            <Text style={css.events_more_label}>Show More News &#9660;</Text>
	          </View>
	        </TouchableHighlight>
	      ) : null }

	      {this.state.topStoriesRenderAllRows === true ? (
	        <TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.setState({topStoriesRenderAllRows: false}) }>
	          <View style={css.events_more}>
	            <Text style={css.events_more_label}>Show Less News &#9650;</Text>
	          </View>
	        </TouchableHighlight>
	      ) : null }
			</View>
    );
  }
}
