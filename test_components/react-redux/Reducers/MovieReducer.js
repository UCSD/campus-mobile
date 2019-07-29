const initialState = {
	movieList: [],
	isLoading: false
}

const MovieReducer = (state = initialState ,action) => {
	switch (action.type) {
		case 'SET_MOVIES':
			return {
				...state,
				movieList: action.movies
			}
		case 'DELETE_MOVIES':
			return {
				...state,
				movieList: []
			}
		case 'SET_LOADING':
			return {
				...state,
				isLoading: action.isLoading
			}
		default:
			return state
	}
}
export default MovieReducer