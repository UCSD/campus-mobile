import React, { Component } from 'react'
// import {
// 	ListView,
// 	ScrollView,
// 	View,
// 	Text,
// } from 'react-native'
import {
	FlatList,
	ScrollView,
	View,
	Text,
} from 'react-native'

import Touchable from '../common/Touchable'
import CircleCheckBox from '../common/CircleCheckBox'
import css from '../../styles/css'
import COLOR from '../../styles/ColorConstants'

/**
 * @param {String[]} items - items to be selected
 * @param {String[]} selected - items already selected
 * @param {Object} themes - coloring for items
 * @param {Function} onSelect - selected item
 * @return {JSX} Return MultiSelect JSX
 */
class MultiSelect extends Component {
	// Returns true if item is being selected
	// false if being de-selected
	onSelect = (item) => {
		const currSelected = this.props.selected.slice()
		const itemIndex = currSelected.indexOf(item)

		if (itemIndex > -1) {
			currSelected.splice(itemIndex, 1)
			this.props.onSelect(currSelected)
			return true
		} else {
			currSelected.push(item)
			this.props.onSelect(currSelected)
			return false
		}
	}

	onClear = () => {
		this.props.onSelect([])
	}

	render() {
		const { items, themes, selected } = this.props

		return (
			<View style={css.main_full_flex}>
				<ScrollView style={css.scroll_default} contentContainerStyle={css.specialevents_filter}>
					<FlatList
						data={items}
						keyExtractor={item => item}
						renderItem={item => (
							<MultiSelectItem
								data={item.item}
								selected={selected.includes(item.item)}
								onSelect={this.onSelect}
								color={(themes && themes[item.item] !== '') ? (themes[item.item]) : (COLOR.DGREY)}
							/>
						)}
						extraData={selected}
					/>
				</ScrollView>

				<Touchable
					onPress={() => this.props.applyFilters()}
					style={css.specialevents_filter_applybutton}
				>
					<Text style={css.specialevents_filter_applybutton_text}>Apply Filters</Text>
				</Touchable>
			</View>
		)
	}
}

const MultiSelectItem = ({ data, selected, onSelect, color }) => (
	<Touchable
		onPress={() => onSelect(data)}
		style={css.specialevents_filter_itemrow}
	>
		<CircleCheckBox
			checked={selected}
			label={data}
			onToggle={() => onSelect(data)}
			outerColor={color}
			innerColor={color}
		/>
	</Touchable>
)

export default MultiSelect
