import React from 'react'
import { TouchableOpacity, View, Text, Switch, Animated } from 'react-native'
import { connect } from 'react-redux';


class Filter extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      filterVal: [false, false, false],
    }

    this.filterOptions = ['Lower division', 'Upper division', 'Graduate division']
    this.onToggleSwitch = this.onToggleSwitch.bind(this)
    this.onClearPressed = this.onClearPressed.bind(this)
  }

  onToggleSwitch = (val, index) => {
    const { filterVal } = this.state
    filterVal[index] = val;
    this.setState({
      filterVal: filterVal
    })
    //this.props.updateFilter(filterVal);
  }

  onClearPressed = () => {
    this.setState({
      filterVal: [false, false, false]
    })
  }


  render() {
    const { filterVal } = this.state;
    const { filterViewStyle, filterTitle, lineSeparator, optionStyle, clearStyle } = styles

    return (
      <Animated.View style={[filterViewStyle, this.props.style]}>
        <Text style={filterTitle}>Filter</Text>
        <Text style={{ fontSize: 12, lineHeight: 14, color: ' rgba(0, 0, 0, 0.5)', marginTop: 20, alignSelf: 'flex-start' }}>Show Only:</Text>
        <View >
          {this.filterOptions.map((option, index) => (
            <View style={{ paddingLeft: 22, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
              <Text style={optionStyle}>{option}</Text>
              <Switch
                trackColor={{ true: '#006A96', false: 'white' }}
                value={filterVal[index]}
                onValueChange={(val) => this.onToggleSwitch(val, index)}
                style={{
                  transform: [{ scaleX: 0.5 }, { scaleY: 0.5 }]
                }}
              />
            </View>
          ))}
        </View>
        <View style={lineSeparator} />
        <TouchableOpacity onPress={this.onClearPressed} >
          <Text style={clearStyle}>Clear</Text>
        </TouchableOpacity>
      </Animated.View>
    )
  }
}

const styles = {
  filterViewStyle: {
    zIndex: 1000,
    width: 200,
    height: 210,
    borderTopLeftRadius: 10,
    borderBottomLeftRadius: 10,
    position: 'absolute',
    top: 55,
    right:0,
    flexDirection: 'column',
    alignItems: 'center',
    paddingHorizontal: 12,
    backgroundColor: '#fff',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0.1,
    shadowRadius: 2,
  },
  filterTitle: {
    fontSize: 18,
    lineHeight: 21,
    fontWeight: 'bold',
    top: 12
  },
  optionStyle: {
    fontSize: 12,
    lineHeight: 14,
  },
  lineSeparator: {
    borderWidth: 0.5,
    width: 200 - 20,
    height: 0.5,
    marginVertical: 13,
    borderColor: 'rgba(0, 0, 0, 0.1)'
  },
  clearStyle: {
    fontSize: 18,
    lineHeight: 20,
    color: '#034263',
    textAlign: 'center'
  }
}

const mapDispatchToProps = dispatch => (
  {
    updateFilter: (filterVal) => {
      dispatch({
        type: 'UPDATE_FILTER_VALUE',
        filterVal
      })
    },
  }
)

export default connect(null, mapDispatchToProps)(Filter);