import React, { Component } from 'react';
import {
	ListView,
	StyleSheet,
	View,
	Text,
} from 'react-native';
import CircleCheckBox from 'react-native-circle-checkbox';

import Touchable from '../common/Touchable';
import {
	COLOR_LGREY,
	COLOR_DGREY,
} from '../../styles/ColorConstants';

/**
 * @param {String[]} items - items to be selected
 * @param {String[]} selected - items already selected
 * @param {Object} themes - coloring for items
 * @param {Function} onSelect
 */
class MultiSelect extends Component {
	// Returns true if item is being selected
	// false if being de-selected
	onSelect = (item) => {
		const currSelected = this.props.selected.slice();
		const itemIndex = currSelected.indexOf(item);

		if (itemIndex > -1) {
			currSelected.splice(itemIndex, 1);
			this.props.onSelect(currSelected);
			return true;
		} else {
			currSelected.push(item);
			this.props.onSelect(currSelected);
			return false;
		}
	}

	onClear = () => {
		this.props.onSelect([]);
	}

	render() {
		const { items, themes, selected } = this.props;
		const ds = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });
		const dataSource = ds.cloneWithRows(items);

		return (
			<View>
				<Touchable
					onPress={() => this.onClear()}
					style={styles.itemRow}
				>
					<Text>
						Clear
					</Text>
				</Touchable>
				<ListView
					dataSource={dataSource}
					renderRow={(rowData) => (
						<MultiSelectItem
							data={rowData}
							selected={selected.includes(rowData)}
							onSelect={this.onSelect}
							color={(themes && themes[rowData] !== '') ? (themes[rowData]) : (COLOR_DGREY)}
						/>
					)}
				/>
			</View>
		);
	}
}

const MultiSelectItem = ({ data, selected, onSelect, color }) => (
	<Touchable
		onPress={() => onSelect(data)}
		style={styles.itemRow}
	>
		<CircleCheckBox
			checked={selected}
			label={data}
			onToggle={() => onSelect(data)}
			outerColor={color}
			innerColor={color}
		/>
	</Touchable>
);

const styles = StyleSheet.create({
	itemRow: { flexDirection: 'row', height: 50, alignItems: 'center', backgroundColor: 'white', borderBottomWidth: 1, borderBottomColor: COLOR_LGREY, },
});

export default MultiSelect;
