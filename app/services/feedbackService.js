import Device from 'react-native-device-info'

const { FEEDBACK_URL } = require('../AppSettings')

const FeedbackService = {
	FetchFeedback(feedback) {
		const brand = Device.getBrand()
		const model = Device.getModel()
		const deviceId = Device.getDeviceId()
		const systemName = Device.getSystemName()
		const systemVersion = Device.getSystemVersion()
		const bundleId = Device.getBundleId()
		const version = Device.getVersion()
		const buildNumber = Device.getBuildNumber()


		const formData = new FormData()
		formData.append('element_1', feedback.comment)
		formData.append('element_2', feedback.name)
		formData.append('element_3', feedback.email)
		formData.append(
			'element_4',
			'\nDevice Brand: ' + brand
			+ '\nDevice Model: ' + model
			+ '\nDevice ID: ' + deviceId
			+ '\nSystem Name: ' + systemName
			+ '\nSystem Version: ' + systemVersion
			+ '\nBundle ID: ' + bundleId
			+ '\nApp Version: ' + version
			+ '\nBuild Number: ' + buildNumber
		)
		formData.append('form_id','175631')
		formData.append('submit_form','1')
		formData.append('page_number','1')
		formData.append('submit_form','Submit')

		return fetch(FEEDBACK_URL, {
			method: 'POST',
			body: formData
		})
			.then(response => (response))
			.catch(error => (error))
	}
}

export default FeedbackService
