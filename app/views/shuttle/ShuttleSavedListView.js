import React from 'react';
import {
	View,
	Text,
	StyleSheet,
	ListView,
	Dimensions,
	TouchableOpacity
} from 'react-native';
import SortableList from 'react-native-sortable-list';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { connect } from 'react-redux';

import css from '../../styles/css';


const deviceWidth = Dimensions.get('window').width;
const savedDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

class ShuttleSavedListView extends React.Component {
	componentWillMount() {
		const savedStops = this.props.savedStops.slice();
		const { closestStop } = this.props;
		
		savedStops.splice(closestStop.savedIndex, 0, closestStop);
		const savedObject = {};
		for (let i = 0; i < savedStops.length; ++i) {
			savedObject[i] = savedStops[i];
		}
		this.setState({ savedObject });
	}

	shouldComponentUpdate() {
		return false; // stop list from re-rendering
	}

	render() {
		return (
			<SortableList
				style={[css.main_container, css.scroll_main, css.whitebg]}
				data={this.state.savedObject}
				renderRow={
					({ data, active, disabled }) =>
						<SavedItem
							data={data}
							active={active}
						/>
				}
				onChangeOrder={(nextOrder) => { this._order = nextOrder; }}
				onReleaseRow={(key) => this.props.orderStops(this._order)}
			/>
		);
	}
}

const SavedItem = ({ data, active }) => (
	<TouchableOpacity
		style={styles.list_row}
	>
		<Icon
			name="drag-handle"
			size={20}
		/>
		<Text style={{ margin: 7 }}>
			{
				(data.closest) ? ('Closest Stop') : (data.name.trim())
			}
		</Text>
	</TouchableOpacity>
);

function mapStateToProps(state, props) {
	return {
		savedStops: state.shuttle.savedStops,
		closestStop: state.shuttle.closestStop
	};
}

function mapDispatchtoProps(dispatch) {
	return {
		orderStops: (newOrder) => {
			dispatch({ type: 'ORDER_STOPS', newOrder });
		}
	};
}

const styles = StyleSheet.create({
	list_row: { backgroundColor: '#FFF', flexDirection: 'row', alignItems: 'center', width: deviceWidth, padding: 7, borderBottomWidth: 1, borderBottomColor: '#EEE'  },
});

export default connect(
	mapStateToProps,
	mapDispatchtoProps
)(ShuttleSavedListView);

/*
<ListView
		style={[css.main_container, css.scroll_main, css.whitebg]}
		dataSource={savedDataSource.cloneWithRows(savedStops)}
		renderRow={
			(row, sectionID, rowID) =>
				<SavedItem
					data={row}
					index={rowID}
				/>
		}
	/>
 */