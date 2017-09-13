import React from 'react';
import {
	View,
	Text,
	ScrollView,
	Image,
	ListView,
	StyleSheet
} from 'react-native';
import moment from 'moment';
import { connect } from 'react-redux';
import {
	COLOR_DGREY,
	COLOR_MGREY,
	COLOR_BLACK,
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

const SurfList = ({ surfData }) => {
	return (
		<ListView
			dataSource={surfData}
			renderRow={
				(row, sectionID, rowID) => (
					<SurfItem
						data={row}
					/>
				)
			}
			renderSectionHeader={(sectionData, day) => {

				var dateDayOfWeek = sectionData[0].surfDayOfWeek;
				var dateDayAndMonth = sectionData[0].surfMonth + ' ' + sectionData[0].surfDayOfMonth;
				var surfTimestampNumeric = sectionData[0].surfTimestampNumeric;
				var currentDate = moment().format('YYYYMMDD');

				return (
					<View style={[styles.dateDayContainer, (currentDate !== surfTimestampNumeric) ? styles.hide : null]}>
						<View style={styles.dateDayHeader}>
							<Text style={styles.dateDayOfWeek}>{dateDayOfWeek}</Text>
							<Text style={styles.dateDayAndMonth}>{dateDayAndMonth}</Text>
						</View>
						<View style={styles.dateDayEmpty} />
					</View>
				);
			}}
		/>
	);
}

const SurfItem = ({ data }) => {

	var currentDate = moment().format('YYYYMMDD');
	
	return (
		<View style={[styles.surfDetailsContainer, (currentDate !== data.surfTimestampNumeric) ? styles.hide : null]}>
			<View style={styles.surfDetailsEmpty} />
			<View style={styles.surfDetails}>
				<Text style={styles.titleText}>{data.surfTitle}</Text>
				<Text style={styles.heightText}>{data.surfHeight}</Text>
				{data.surfDesc ? (<Text style={styles.descText}>{data.surfDesc}</Text>) : null }
			</View>
		</View>
	);
}

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
	hide: { opacity: 0, height: 0 },
	dayText: { fontSize: 19, color: COLOR_BLACK, position: 'absolute', marginTop: 50, borderWidth: 1 },
	surfDetailsContainer: { flexDirection: 'row' },
	surfDetailsEmpty: { flex: 1 },
	surfDetails: { flex: 2.5, borderLeftWidth: 1, borderLeftColor: COLOR_MGREY, marginVertical: 10, paddingHorizontal: 10 },
	titleText: { fontSize: 18, color: COLOR_BLACK },
	heightText: { fontSize: 16, color: COLOR_DGREY, paddingTop: 4 },
	descText: { fontSize: 13, color: COLOR_DGREY, paddingTop: 4 },
	dateDayContainer: { position: 'absolute', flexDirection: 'row', top: 10 },
	dateDayHeader: { flex: 1, alignItems: 'center', justifyContent: 'center' },
	dateDayEmpty: { flex: 2.5 },
	dateDayOfWeek: { fontSize: 19, color: 'black' },
	dateDayAndMonth: { fontSize: 12, color: COLOR_DGREY },
});

export default ActualSurfReport;
