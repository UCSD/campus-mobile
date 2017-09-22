import React, { Component } from 'react';
import {
	ListView,
	StyleSheet,
	View,
	Text,
} from 'react-native';
import { Actions } from 'react-native-router-flux';
import Touchable from '../common/Touchable';
import CircleCheckBox from '../common/CircleCheckBox';
import {
	COLOR_LGREY,
	COLOR_DGREY,
	COLOR_WHITE,
	COLOR_PRIMARY,
} from '../../styles/ColorConstants';
import { WINDOW_WIDTH } from '../../styles/LayoutConstants';

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
			<View style={styles.container}>
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

				<Touchable
					onPress={() => this.props.applyFilters()}
					style={styles.applyButton}
				>
					<Text style={styles.applyText}>Apply</Text>
				</Touchable>
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
	container: { backgroundColor: 'white', paddingBottom: 60, borderWidth: 1 },
	itemRow: { flexDirection: 'row', height: 50, alignItems: 'center', backgroundColor: 'white', borderBottomWidth: 1, borderBottomColor: COLOR_LGREY, paddingHorizontal: 12 },
	applyButton: { position: 'absolute', width: Math.round(WINDOW_WIDTH * .9), height: 40, bottom: 10, left: Math.round(WINDOW_WIDTH * .05), justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR_PRIMARY, borderRadius: 3, padding: 10 },
	applyText: { fontSize: 16, color: COLOR_WHITE },
});

export default MultiSelect;
