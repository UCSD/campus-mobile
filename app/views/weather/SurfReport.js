import React from 'react';
import {
	View,
	Text,
	ScrollView,
	Image,
	ListView,
} from 'react-native';

import { connect } from 'react-redux';

const css = require('../../styles/css');
const logger = require('../../util/logger');

const surfDataSource = new ListView.DataSource({
	rowHasChanged: (r1, r2) => r1 !== r2,
	sectionHeaderHasChanged: (s1, s2) => s1 !== s2 });
const surfHeader = require('../../assets/img/surf_report_header.jpg');

const SurfReport = ({ surfData }) => {
	logger.log('View Mounted: Surf');

	return (<SurfView
		surfData={surfData}
	/>);
};

// This stuff should be moved to different files, but we should be redoing this view soon
const SurfView = ({ surfData }) => (
	<View style={[css.main_container, css.whitebg]}>
		<ScrollView contentContainerStyle={[css.scroll_main, css.whitebg]}>
			<Image
				style={css.sr_image}
				source={surfHeader}
			/>
			{surfData ? (
				<SurfList
					surfData={surfDataSource.cloneWithRowsAndSections(surfData)}
				/>
			) : null }
			{!surfData ? (
				<Text style={[css.center, css.pad40]}>There is no surf data available at this time.{'\n'}Please check back later.</Text>
			) : null }
		</ScrollView>
	</View>
);

const SurfList = ({ surfData }) => (
	<ListView
		dataSource={surfData}
		style={css.wf_listview}
		renderRow={
			(row, sectionID, rowID) => (
				<SurfItem
					data={row}
				/>
			)
		}
		renderSectionHeader={(sectionData, day) => (
			<Text
				style={[css.sr_dayofweek,
					{ padding: 10 }]}
			>
				{day}
			</Text>
		)}
	/>
);

const SurfItem = ({ data }) => (
	<View style={css.sr_day_row}>
		<View style={css.sr_day_details_container}>
			<View style={css.sr_day_details_container_inner}>
				<Text style={css.sr_day_details_title}>{data.surfTitle}</Text>
				<Text style={css.sr_day_details_height}>{data.surfHeight}</Text>
				{data.surfDesc ? (<Text style={css.sr_day_details_desc}>{data.surfDesc}</Text>) : null }
			</View>
		</View>
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

export default ActualSurfReport;
