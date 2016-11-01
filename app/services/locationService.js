
export function getPosition() {
	return new Promise((resolve, reject) => {
		navigator.geolocation.getCurrentPosition(
				(position) => { resolve(position); },
				(error) => { reject(error); }
			);
	});
}

export function getPermission() {
	return new Promise((resolve, reject) => {
	});
}
