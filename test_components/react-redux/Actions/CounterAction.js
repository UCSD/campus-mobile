import { connect } from 'react-redux';

import * as Actions from './ActionTypes';
import CounterComponent from '../Components/CounterComponent'

const mapStateToProps = (state) => ({
     count: state.CounterReducer.count
});

const mapDispatchToProps = (dispatch) => ({
    increment: () => dispatch({type: Actions.COUNTER_INCREMENT}),
    decrement: () => dispatch({type: Actions.COUNTER_DECREMENT}),
});

export default connect(mapStateToProps, mapDispatchToProps)(CounterComponent);
