// Usage: replace_all.js [Production|Staging|Placeholder]

var fork = require('child_process').fork;

var REPLACEMENT_TYPE = process.argv[2];

if (REPLACEMENT_TYPE === 'Production' || REPLACEMENT_TYPE === 'Staging' || REPLACEMENT_TYPE === 'Placeholder') {
	fork('./replace_app_name.js', [REPLACEMENT_TYPE]);
	fork('./replace_codepush_key.js', [REPLACEMENT_TYPE]);
	fork('./replace_google_analytics_id.js', [REPLACEMENT_TYPE]);
	fork('./replace_google_maps_api_key.js', [REPLACEMENT_TYPE]);
} else {
	console.log('Error: Replacement type not specififed');
	console.log('Sample Usage: replace_all.js [Production|Staging|Placeholder]');
}
