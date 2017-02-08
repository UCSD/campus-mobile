import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	ActivityIndicator,
	StyleSheet
} from 'react-native';
import { connect } from 'react-redux';
import { Actions } from 'react-native-router-flux';

import Card from '../card/Card';
import CardComponent from '../card/CardComponent';
import DiningList from './DiningList';
import LocationRequiredContent from '../common/LocationRequiredContent';
import { getMaxCardWidth } from '../../util/general';

const css = require('../../styles/css');
const logger = require('../../util/logger');

class DiningCardContainer extends CardComponent {
	componentDidMount() {
		logger.ga('Card Mounted: Dining');
	}

	render() {
		const { diningData, locationPermission } = this.props;

		return (
			<DiningCard
				data={diningData}
				rows={4}
				permission={locationPermission}
			/>
		);
	}

	gotoDiningListView = () => {
		Actions.DiningListView({ data: this.props.diningData });
	}
}

function mapStateToProps(state, props) {
	return {
		diningData: state.dining.data,
		locationPermission: state.location.permission,
	};
}

const ActualDiningCard = connect(
	mapStateToProps,
)(DiningCardContainer);

export default ActualDiningCard;

const DiningCard = ({ data, rows, permission }) => {
	let content;
	// no permission to get location
	if (permission !== 'authorized') {
		content = (<LocationRequiredContent />);
	} else if (data === null) {
		content =  (
			<View style={[styles.card_row_center, styles.card_loader]}>
				<ActivityIndicator size="large" />
			</View>
		);
	} else {
		content = (
			<View style={css.dining_card}>
				<View style={css.dc_locations}>
					<DiningList data={data} rows={rows} />
				</View>
				<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => Actions.DiningListView({ data })}>
					<View style={css.events_more}>
						<Text style={css.events_more_label}>View All Locations</Text>
					</View>
				</TouchableHighlight>
			</View>
		);
	}

	return (
		<Card id="dining" title="Dining">
			{content}
		</Card>
	);
};

const styles = StyleSheet.create({
	card_row_center: { alignItems: 'center', justifyContent: 'center', width: getMaxCardWidth(), overflow: 'hidden' },
	card_loader: { height: 100 },
});
