import { OCCUSPACE_API_URL_MOCK } from '../AppSettings'
import { authorizedPublicFetch } from '../util/auth'

const OccuspaceService = {
	* FetchOccuspace() {
		try {
			const data = (yield authorizedPublicFetch(OCCUSPACE_API_URL_MOCK + '/busyness'))
			return data
		} catch (error) {
			throw error
		}
	},
}

export default OccuspaceService