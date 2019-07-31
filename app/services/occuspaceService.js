import { OCCUSPACE_API_URL } from '../AppSettings'
import { authorizedPublicFetch } from '../util/auth'

const OccuspaceService = {
	* FetchOccuspace() {
		try {
			const data = (yield authorizedPublicFetch(OCCUSPACE_API_URL + '/busyness'))
			return data
		} catch (error) {
			throw error
		}
	},
}

export default OccuspaceService