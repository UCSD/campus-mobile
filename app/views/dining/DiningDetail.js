import React from 'react';
import {
	View,
	ScrollView,
} from 'react-native';
import { connect } from 'react-redux';

import logger from '../../util/logger';
import DiningDescription from './DiningDescription';
import DiningImages from './DiningImages';
import DiningDirections from './DiningDirections';
import DiningMenu from './DiningMenu';

const css = require('../../styles/css');

class DiningDetail extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			filters: [],
			activeMeal: 'Breakfast',
		};
	}

	componentDidMount() {
		this.props.getMenuItems(this.props.data.id);
		logger.ga('View Mounted: Dining Detail');
	}

	addFilter = (filter) => {
		if (filter === 'Breakfast' || filter === 'Lunch' || filter === 'Dinner') {
			this.setState({
				activeMeal: filter
			});
		} else {
			if (this.state.filters.indexOf(filter) < 0) {
				// Add filter
				this.setState({
					filters: [...this.state.filters, filter]
				});
			} else {
				// Remove filter
				const temp = [...this.state.filters];
				temp.splice(temp.indexOf(filter), 1);
				this.setState({
					filters: temp
				});
			}
		}
	}

	render() {
		const { data } = this.props;
		return (
			<View style={css.main_full}>
				<ScrollView contentContainerStyle={[css.scroll_main, css.whitebg]}>
					<DiningDescription
						name={data.name}
						description={data.description}
						regularHours={data.regularHours}
						specialHours={data.specialHours}
						paymentOptions={data.paymentOptions}
					/>
					<DiningImages
						images={data.images}
					/>
					<DiningDirections
						latitude={data.coords.lat}
						longitude={data.coords.lon}
						distance={data.distanceMilesStr}
					/>
					<DiningMenu
						data={data}
						filters={this.state.filters}
						activeMeal={this.state.activeMeal}
						addFilter={filter => this.addFilter(filter)}
					/>
				</ScrollView>
			</View>
		);
	}
}

const mapDispatchToProps = dispatch => (
	{
		getMenuItems: (menuId) => {
			dispatch({ type: 'UPDATE_DINING', menuId });
		}
	}
);

export default connect(null, mapDispatchToProps)(DiningDetail);
