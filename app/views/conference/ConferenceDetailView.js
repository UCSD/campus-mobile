import React from 'react';
import {
	View,
	Text,
	ScrollView,
	StyleSheet,
} from 'react-native';
import { connect } from 'react-redux';
import Icon from 'react-native-vector-icons/Ionicons';
import moment from 'moment';
import Touchable from '../common/Touchable';
import css from '../../styles/css';
import logger from '../../util/logger';

import { getHumanizedDuration, getCampusPrimary, platformIOS } from '../../util/general';

const ConferenceDetailView = ({ data, saved, add, remove }) => {
	logger.ga('View Loaded: Conference Detail: ' + data['talk-title']);

	return (
		<View style={[css.main_container, css.whitebg]}>
			<ScrollView>
				<View style={css.news_detail_container}>

					<View style={styles.starButton}>
						<Touchable
							onPress={
								() => (isSaved(saved, data.id) ? (remove(data.id)) : (add(data.id)))
							}
						>
							<View style={styles.starButtonInner}>
								<Icon
									name={'ios-star-outline'}
									size={32}
									color={'#999'}
									style={styles.starOuterIcon}
								/>
								{ isSaved(saved, data.id)  ? (
									<Icon
										name={'ios-star'}
										size={26}
										color={'yellow'}
										style={styles.starInnerIcon}
									/>
								) : null }
							</View>
						</Touchable>
					</View>

					<View style={styles.labelView}>
						{ data.label ? (
							<Text style={[styles.labelText, { color: data['label-theme'] ? data['label-theme'] : COLOR_BLACK }]}>{data.label}</Text>
						) : null }
						{ data['talk-type'] === 'Keynote' ? (
							<Text style={styles.labelText}>{data['talk-type']}</Text>
						) : null }
						{ data.label || data['talk-type'] === 'Keynote' ? (
							<Text style={styles.labelText}> - </Text>
						) : null }
						<Text style={styles.labelText}>{getHumanizedDuration(data['start-time'], data['end-time'])}</Text>
					</View>

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

function isSaved(savedArray, id) {
	if (Array.isArray(savedArray)) {
		for ( let i = 0; i < savedArray.length; ++i) {
			if (savedArray[i] === id) {
				return true;
			}
		}
	}
	return false;
}

const mapStateToProps = (state) => (
	{
		saved: state.conference.saved
	}
);

const ActualConferenceDetailView = connect(
	mapStateToProps
)(ConferenceDetailView);

const styles = StyleSheet.create({
	labelView: { flexDirection: 'row', paddingTop: 4 },
	labelText: { fontSize: 13 },
	sessionName: { fontSize: 22, color: '#000', paddingTop: 6 },
	sessionInfo: { fontSize: 13, paddingTop: 6  },
	sessionDesc: { lineHeight: 18, color: '#000', fontSize: 14, paddingTop: 14 },
	hostedBy: { fontSize: 13, fontWeight: '600', marginTop: 20 },
	speakerContainer: { marginTop: 2 },
	speakerName: { fontSize: 13, fontWeight: '600', color: getCampusPrimary(), marginTop: 10 },
	speakerPosition: { fontSize: 11, marginTop: 2 },
	speakerSubTalkTitle: { fontSize: 11, marginTop: 2 },
	starButton: { width: 50, position: 'absolute', top: 2, right: -5, zIndex: 10 },
	starButtonInner: { justifyContent: 'flex-start', alignItems: 'center' },
	starOuterIcon: { position: platformIOS() ? 'absolute' : 'relative', zIndex: 10, backgroundColor: 'rgba(0,0,0,0)' },
	starInnerIcon: { position: 'absolute', zIndex: platformIOS() ? 5 : 15, marginTop: 3 },
});

export default ActualConferenceDetailView;
