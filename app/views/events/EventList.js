
import React from 'react'
import {
	View,
  ListView,
	Text,
	TouchableHighlight,
} from 'react-native';
import EventItem from './EventItem'

var css = require('../../styles/css');

export default class EventList extends React.Component {

  constructor(props){
    super(props);

		this.state = {
			eventsRenderAllRows: false
		}

    this.datasource = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
  }

  render() {
    var eventData = [];
    if (this.state.eventsRenderAllRows){
      eventData = this.props.data;
    } else {
      eventData = this.props.data.slice(0, 3);
    }

    var eventDatasource = this.datasource.cloneWithRows(eventData);

    return (
			<View>
	      <ListView
	        dataSource={eventDatasource}
	        renderRow={ (row) => <EventItem data={row} navigator={this.props.navigator} /> }
	        style={css.wf_listview} />

	      {this.state.eventsRenderAllRows === false ? (
	        <TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.setState({eventsRenderAllRows: true}) }>
	          <View style={css.events_more}>
	            <Text style={css.events_more_label}>Show More Events &#9660;</Text>
	          </View>
	        </TouchableHighlight>
	      ) : null }

	      {this.state.eventsRenderAllRows === true ? (
	        <TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.setState({eventsRenderAllRows: false}) }>
	          <View style={css.events_more}>
	            <Text style={css.events_more_label}>Show Less Events &#9650;</Text>
	          </View>
	        </TouchableHighlight>
	      ) : null }
			</View>
    );
  }
}
