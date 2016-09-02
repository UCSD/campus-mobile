'use strict';

import React from 'react';
import {
	AsyncStorage
} from 'react-native';

var logger = require('./logger');

var storage = {

	save(key, val) {
		try {
			await AsyncStorage.setItem(key, val);
		} catch (error) {
			logger.error('ERR: storage.save: ' + error);
		}
	}

	get() {
		try {
			const value = await AsyncStorage.getItem(key);

			logger.log('value: ' + value);

		} catch (error) {
			logger.error('ERR: storage.get: ' + error);
		}
	}

}

export default storage;