'use strict';

import React from 'react';
import {
	View,
	Text,
	TextInput,
	TouchableOpacity,
	ScrollView,
	Image,
	AlertIOS,
} from 'react-native';

var css = require('../styles/css');
var logger = require('../util/logger');

var DestionationSearch = React.createClass({

	getInitialState: function() {
		return {
			inputPlaceholderText: "Where are you going?",
		}
	},

	render: function() {
		return this.renderScene();
	},

	renderScene: function(route, navigator) {
		return (
			<View style={[css.main_container, css.offwhitebg]}>
				<ScrollView contentContainerStyle={css.scroll_default}>

					<View style={css.dsearch_container}>
						<View style={css.dsearch_inner}>

							<TouchableOpacity onPress={ () => AlertIOS.alert('Search Icon Trigger') }>
								<Image style={css.dsearch_searchicon} source={ require('image!icon_destinationsearch') } />
							</TouchableOpacity>

							<TextInput
								style={css.dsearch_textinput}
								onChangeText={ (text) => { this.onChangeText(text) } }
								value={this.state.inputPlaceholderText}
								returnKeyType={'search'}
								clearTextOnFocus={true}
								placeholderTextColor={'red'}
								onSubmitEditing={this.gotoDestinationSuggestions} />

							<TouchableOpacity onPress={ () => AlertIOS.alert('Mic Icon Trigger') }>
								<Image style={css.dsearch_micicon} source={ require('image!icon_mic') } />
							</TouchableOpacity>

						</View>
					</View>

				</ScrollView>
			</View>
		);
	},

	onChangeText: function(inputText) {

	},

	gotoDestinationSuggestions: function() {
		this.props.navigator.push({
			id: 'DestinationSuggestions',
			name: "DestinationSuggestions",
		});
	},
});

module.exports = DestionationSearch;