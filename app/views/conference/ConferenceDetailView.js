import React from 'react';
import {
	View,
	Text,
	ScrollView,
	Image,
	Linking,
	Dimensions,
	StyleSheet,
} from 'react-native';

import moment from 'moment';

import SafeImage from '../common/SafeImage';
import css from '../../styles/css';
import logger from '../../util/logger';
import { getHumanizedDuration, getCampusPrimary } from '../../util/general';

const ConferenceDetailView = ({ data }) => {
	logger.ga('View Loaded: Event Detail: ' + data['talk-title']);

	return (
		<View style={[css.main_container, css.whitebg]}>
			<ScrollView>
				<View style={css.news_detail_container}>
					<Text style={styles.labelText}>
						{ data.label ? (
							<Text>{data.label} - </Text>
						) : null }
						{ data['talk-type'] === 'Keynote' ? (
							<Text>{data['talk-type']} - </Text>
						) : null }
						{getHumanizedDuration(data['start-time'], data['end-time'])}
					</Text>
					<Text style={styles.sessionName}>
						{data['talk-title']}
					</Text>
					<Text style={styles.sessionInfo}>
						{data.location} - {moment(Number(data['start-time'])).format('MMM Do YYYY, h:mm a')}
					</Text>

					<Text style={styles.sessionDesc}>
						{data['full-description']}
					</Text>

					{data.speakers ? (
						<View>
							<Text style={styles.hostedBy}>Hosted By</Text>
							{data.speakers.map((object, i) => (
								<View style={styles.speakerContainer} key={i}>
									<Text style={styles.speakerName}>{object.name}</Text>
									<Text style={styles.speakerPosition}>{object.position}</Text>
									{/*<Text style={styles.speakerSubTalkTitle}>{object['sub-talk-title']}</Text>*/}
								</View>
							))}
						</View>
					) : null }
				</View>
			</ScrollView>
		</View>
	);
};

const styles = StyleSheet.create({
	labelText: { fontSize: 12 },
	sessionName: { fontSize: 22, color: getCampusPrimary(), paddingTop: 6 },
	sessionInfo: { fontSize: 12, paddingTop: 6  },
	sessionDesc: { lineHeight: 18, color: '#111', fontSize: 14, paddingTop: 14 },
	hostedBy: { fontSize: 10, fontWeight: 'bold', marginTop: 20 },
	speakerContainer: { marginTop: 2 },
	speakerName: { fontSize: 14, fontWeight: 'bold', color: getCampusPrimary(), marginTop: 10 },
	speakerPosition: { fontSize: 10, marginTop: 2 },
	speakerSubTalkTitle: { fontSize: 10, marginTop: 2 },
});

export default ConferenceDetailView;
