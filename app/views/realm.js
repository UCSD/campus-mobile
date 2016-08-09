'use strict';

import Realm from 'realm';

var AppSettings = 		require('../AppSettings');

export default new Realm({schema: [AppSettings.DB_SCHEMA], schemaVersion: 2});
