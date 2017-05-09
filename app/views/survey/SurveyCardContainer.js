import React from 'react';
import { connect } from 'react-redux';
import Toast from 'react-native-simple-toast';

import YesNoCard from './YesNoCard';
import CardComponent from '../card/CardComponent';

class SurveyCardContainer extends CardComponent {
	constructor(props) {
		super(props);
		this.state = {
			show: false,
			id: -1
		};
	}

	componentWillReceiveProps(nextProps) {
		const id = this._hasSurvey(nextProps);
		if (id) {
			this.setState({
				show: true,
				id
			});
		}
	}

	_hasSurvey = (props) => {
		const { surveyIds, surveysDone, lastAnswered } = props;
		const nowTime = new Date().getTime();
		const timeDiff = 24 * 60 * 60 * 1000; // 24 hours
		const goTime = (nowTime - lastAnswered) > timeDiff;
		let todo;

		// only give new survey if 24 hours pass
		if (goTime) {
			for (let i = 0; i < surveyIds.length; ++i) {
				const id = surveyIds[i];
				if (!surveysDone.includes(id)) {
					todo = id;
					break;
				}
			}
		}
		return todo;
	}

	_handleAnswer = (answer) => {
		this.props.submitSurvey(this.state.id, answer);
		this.setState({
			show: false
		});
		if (answer !== 'dismiss') {
			Toast.showWithGravity('Thank you for the input.', Toast.SHORT, Toast.CENTER);
		}
	}

	render() {
		if (this.state.show) {
			const survey = this.props.surveys[this.state.id];
			return (
				<YesNoCard
					question={survey.question}
					id={survey.id}
					onPress={this._handleAnswer}
					data
				/>
			);
		} else {
			return null;
		}
	}
}

function mapStateToProps(state, props) {
	return {
		surveys: state.survey.byId,
		surveyIds: state.survey.allIds,
		surveysDone: state.survey.doneIds,
		lastAnswered: state.survey.lastAnswered
	};
}

function mapDispatchtoProps(dispatch) {
	return {
		submitSurvey: (id, answer, data) => {
			dispatch({ type: 'SURVEY_SUBMITTED', id, answer, data });
		}
	};
}

const ActualSurveyCard = connect(
	mapStateToProps,
	mapDispatchtoProps
)(SurveyCardContainer);

export default ActualSurveyCard;
