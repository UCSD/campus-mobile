import Device from 'react-native-device-info';

const { FEEDBACK_URL } = require('../AppSettings');

const FeedbackService = {
	FetchFeedback(feedback) {
		const formData = new FormData();
		formData.append('element_1', feedback.comment);
		formData.append('element_2', feedback.name);
		formData.append('element_3', feedback.email);
		formData.append(
			'element_4',
			'Device Manufacturer: ' + Device.getManufacturer() + '\n' +
			'Device Brand: ' + Device.getBrand() + '\n' +
			'Device Model: ' + Device.getModel() + '\n' +
			'Device ID: ' + Device.getDeviceId() + '\n' +
			'System Name: ' + Device.getSystemName() + '\n' +
			'System Version: ' + Device.getSystemVersion() + '\n' +
			'Bundle ID: ' + Device.getBundleId() + '\n' +
			'App Version: ' + Device.getVersion() + '\n' +
			'Build Number: ' + Device.getBuildNumber() + '\n' +
			'Device Name: ' + Device.getDeviceName() + '\n' +
			'User Agent: ' + Device.getUserAgent() + '\n' +
			'Device Locale: ' + Device.getDeviceLocale() + '\n' +
			'Device Country: ' + Device.getDeviceCountry() + '\n' +
			'Timezone: ' + Device.getTimezone()
		);
		formData.append('form_id','175631');
		formData.append('submit_form','1');
		formData.append('page_number','1');
		formData.append('submit_form','Submit');

		return fetch(FEEDBACK_URL, {
			method: 'POST',
			body: formData
		})
		.then((response) => (response))
		.catch((error) => (error));
	}
};

export default FeedbackService;
