import React from 'react';
import {
	View,
	Text,
	ScrollView,
	Image,
	ListView,
	StyleSheet
} from 'react-native';

import { connect } from 'react-redux';

import {
	COLOR_DGREY,
	COLOR_BLACK
} from '../../styles/ColorConstants';
import {
	WINDOW_WIDTH
} from '../../styles/LayoutConstants';
import css from '../../styles/css';

const logger = require('../../util/logger');

const surfDataSource = new ListView.DataSource({
	rowHasChanged: (r1, r2) => r1 !== r2,
	sectionHeaderHasChanged: (s1, s2) => s1 !== s2 });
const surfHeader = require('../../assets/img/surf_report_header.jpg');

const SurfReport = ({ surfData }) => {
	logger.log('View Mounted: Surf');

	return (
		<SurfView
			surfData={surfData}
		/>
	);
};

// This stuff should be moved to different files, but we should be redoing this view soon
const SurfView = ({ surfData }) => (
	<ScrollView
		style={css.main_full}
	>
		<Image
			style={styles.headerImage}
			source={surfHeader}
		/>
		{surfData ? (
			<SurfList
				surfData={surfDataSource.cloneWithRowsAndSections(surfData)}
			/>
		) : null }
		{!surfData ? (
			<Text style={[styles.center, styles.pad40]}>There is no surf data available at this time.{'\n'}Please check back later.</Text>
		) : null }
	</ScrollView>
);

const SurfList = ({ surfData }) => (
	<ListView
		dataSource={surfData}
		renderRow={
			(row, sectionID, rowID) => (
				<SurfItem
					data={row}
				/>
			)
		}
		renderSectionHeader={(sectionData, day) => (
			<Text
				style={[styles.dayText,
					{ padding: 10 }]}
			>
				{day}
			</Text>
		)}
	/>
);

const SurfItem = ({ data }) => (
	<View style={styles.detailsContainer}>
		<Text style={styles.titleText}>{data.surfTitle}</Text>
		<Text style={styles.heightText}>{data.surfHeight}</Text>
		{data.surfDesc ? (<Text style={styles.descText}>{data.surfDesc}</Text>) : null }
	</View>
);

const mapStateToProps = (state) => (
	{
		surfData: state.surf.data,
		surfLastUpdated: state.surf.lastUpdated,
	}
);

const ActualSurfReport = connect(
	mapStateToProps
)(SurfReport);

const styles = StyleSheet.create({
	headerImage: { width: WINDOW_WIDTH, height: Math.round(WINDOW_WIDTH * 0.361) },
	dayText: { fontSize: 19, color: COLOR_BLACK },
	detailsContainer: { padding: 10 },
	titleText: { fontSize: 18, color: COLOR_BLACK },
	heightText: { fontSize: 16, color: COLOR_DGREY, paddingTop: 4 },
	descText: { fontSize: 13, color: COLOR_DGREY, paddingTop: 4 },
});

export default ActualSurfReport;
