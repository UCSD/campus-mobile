const AppSettings = require('../AppSettings');

const DiningService = {
	FetchDining() {
		return fetch(AppSettings.DINING_API_URL, {
			headers: {
				'Cache-Control': 'no-cache'
			}
		})
			.then(response => (response.json()))
			.then((data) => {
				if (data.errorMessage) {
					throw (data.errorMessage);
				} else {
					return data.dininginfo;
				}
			})
			.catch(err => console.log('Error fetching dining: ' + err));
	},

	FetchDiningMenu(id) {
		return fetch(`http://hdh2.ucsd.edu/diningmenu/api/DiningDataService/GetDiningInfo_V2/${id}`, {
		// return fetch(`${AppSettings.DINING_API_URL}/${id}`, {
			headers: {
				'Cache-Control': 'no-cache'
			}
		})
			.then(response => (response.json()))
			.then((data) => {
				if (data.Message) {
					throw (data.Message);
				} else {
					return data.menuitems;
				}
			})
			.catch(err => console.log(`Error fetching dining menu for id ${id}: ` + err));
	}
};

export default DiningService;
