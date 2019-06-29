import React from 'react'
import { TouchableOpacity, View, TextInput, Dimensions, Image } from 'react-native'
import Icon from 'react-native-vector-icons/Ionicons'
import NavigationService from '../../navigation/NavigationService'
import { connect } from 'react-redux';
import { withNavigation } from 'react-navigation'

const { width } = Dimensions.get('screen')
class SearchHeader extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      input: '',
      searchedCourse: '',
      showFilter: false,
      optionVal: [false, true, false]
    }

    this.filterOptions = ['Lower division', 'Upper division', 'Graduate division']

    this.onBackBtnPressed = this.onBackBtnPressed.bind(this)
    this.onChangeText = this.onChangeText.bind(this)
    this.onSubmit = this.onSubmit.bind(this)
    this.onFilterPressed = this.onFilterPressed.bind(this)
  }

  onBackBtnPressed = () => {
    NavigationService.navigate('MainTabs')
  }

  onChangeText = (text) => {
    this.setState({ input: text })
  }

  onSubmit = () => {
    const { input } = this.state;
    this.setState({
      searchedCourse: input
    });
    this.props.updateInput(input);
  }

  onFilterPressed = () => {
    const { showFilter } = this.state
    this.setState({
      showFilter: !showFilter
    })
    this.props.showFilter(showFilter);
  }


  renderBackBtn() {
    const { backBtnStyle } = styles;
    return (
      <TouchableOpacity
        style={backBtnStyle}
        onPress={this.onBackBtnPressed}
      >
        <Image
            style={{width:24, height:24}}
            source={require('./backIcon.png')}
        />
      </TouchableOpacity>
    )
  }

  renderBar = () => {
    const { input } = this.state;
    const { barViewStyle, searchIconStyle, inputStyle } = styles

    return (
      <View style={barViewStyle}>
        <Image
            style={searchIconStyle}
            source={require('./searchIcon.png')}
        />
        <TextInput
          style={inputStyle}
          value={input}
          onChangeText={this.onChangeText}
          autoCorrect={false}
          returnKeyType="go"
          onSubmitEditing={this.onSubmit}
        />
      </View>
    )
  }

  renderFilterBtn = () => {
    const { filterBtnStyle, filterIconStyle } = styles

    return (
      <TouchableOpacity
        style={filterBtnStyle}
        onPress={this.onFilterPressed}>
        <Image
          style={filterIconStyle}
          source={require('./filterIcon.png')}
        />
      </TouchableOpacity>
    )
  }


  render() {
    const { searchBarStyle } = styles
    return (
      <View style={searchBarStyle}>
        {this.renderBackBtn()}
        {this.renderBar()}
        {this.renderFilterBtn()}
      </View>)
  }
}

const styles = {
  searchBarStyle: {
    flexDirection: 'row',
    height: 32,
    width: '100%',
    marginTop: 15,
    marginBottom: 15,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0.1,
    shadowRadius: 2,
  },
  backBtnStyle: {
    flex: 0.14,
    justifyContent: 'center',
    alignItems: 'center'
  },
  barViewStyle: {
    flex: 0.72,
    flexDirection: 'row',
    borderWidth: 1,
    borderColor: '#194160',
    borderRadius: 20,
    alignItems:'center',
    justifyContent:'center',
    backgroundColor:'#f1f1f1',
  },
  searchIconStyle: {
    width: 21, 
    height: 21,
    marginHorizontal:7,
  },
  inputStyle: {
    flex:1,
    fontSize: 14,
  },
  filterBtnStyle: {
    flex: 0.14,
    justifyContent: 'center',
    alignItems: 'center'
  },
  filterIconStyle: {
    width: 24,
    height: 24
  },
  lineSeparator: {
    borderWidth: 0.5,
    width: width / 2 - 20,
    height: 0.5,
    marginVertical: 13,
    borderColor: 'rgba(0, 0, 0, 0.1)'
  },
}

const mapDispatchToProps = dispatch => (
	{
		updateInput: (input) => {
			dispatch({
				type: 'UPDATE_INPUT',
				input
			})
		},
		showFilter: (showFilter) => {
			dispatch({ type: 'CHANGE_FILTER_VISIBILITY', showFilter})
		},
	}
)

export default withNavigation(connect(null, mapDispatchToProps)(SearchHeader))