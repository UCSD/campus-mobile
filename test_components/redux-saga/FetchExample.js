import React from 'react'
import { connect } from 'react-redux'
import { FlatList, ActivityIndicator, Text, View, Button  } from 'react-native'


class FetchExample extends React.Component {
	render() {
		if (this.props.isLoading) {
			return (
				<View style={{ flex: 1, padding: 20 }}>
					<ActivityIndicator />
				</View>
			)
		}

		return (
			<View style={{ flex: 1, paddingTop: 20 }}>
				<Button
					onPress={this.props.getMovies}
					title="get movies"
					color="#841584"
				/>
				<Button
					onPress={this.props.deleteMovies}
					title="delete movies"
					color="#841584"
				/>
				<FlatList
					data={this.props.movies}
					renderItem={({ item }) => (
						<Text>
							{item.title}
							{item.releaseYear}
						</Text>
					)}
					keyExtractor={({ id }, index) => id}
				/>
			</View>
		)
	}
}

const mapStateToProps = state => ({
	movies: state.MovieReducer.movieList,
	isLoading: state.MovieReducer.isLoading
})

const mapDispatchToProps = dispatch => ({
	getMovies: () => dispatch({ type: 'GET_MOVIES' }),
	deleteMovies: () => dispatch({ type: 'DELETE_MOVIES' }),
})

export default connect(mapStateToProps, mapDispatchToProps)(FetchExample)