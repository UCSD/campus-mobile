
export function getLocation() {
	return new Promise((resolve, reject) => {
		navigator.geolocation.getCurrentPosition(
				(position) => { resolve(position); },
				(error) => { reject(error); }
			);
	});
}

export function getPermission() {
}
