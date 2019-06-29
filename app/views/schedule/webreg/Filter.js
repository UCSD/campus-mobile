import React from 'react'
import { TouchableOpacity, View, Text, Switch } from 'react-native'



class Filter extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      filterVal: [false, false, false]
    }

    this.filterOptions = ['Lower division', 'Upper division', 'Graduate division']
    this.onToggleSwitch = this.onToggleSwitch.bind(this)
    this.onClearPressed = this.onClearPressed.bind(this)
  }

  onToggleSwitch = ( val, index) => {
    const { filterVal } = this.state
    filterVal[index] = val;
    console.log(index)
    return this.setState({
      filterVal: filterVal
    })
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
      <View style={filterViewStyle}>
        <Text style={filterTitle}>Filter</Text>
        <Text style={{ fontSize: 12, lineHeight: 14, color: ' rgba(0, 0, 0, 0.5)', marginTop: 20, alignSelf:'flex-start'}}>Show Only:</Text>
        <View >
          {this.filterOptions.map((option, index) => (
            <View style={{paddingLeft:22,flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
              <Text style={optionStyle}>{option}</Text>
              <Switch
                trackColor={{ true: '#006A96', false: 'white' }}
                value={filterVal[index]}
                onValueChange={(val) => onToggleSwitch(val, index)}
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

      </View>
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
    right: 0,
    flexDirection: 'column',
    alignItems: 'center',
    borderWidth: 1,
    paddingHorizontal: 12,
    backgroundColor:'#fff'
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
    color:'#034263',
    textAlign: 'center'
  }
}

export default Filter;