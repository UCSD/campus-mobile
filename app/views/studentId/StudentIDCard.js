import React from 'react'
import { View, Text, Image, ActivityIndicator } from 'react-native'
import Barcode from 'react-native-barcode-builder'
import Modal from 'react-native-modal'
import Card from '../common/Card'
import Touchable from '../common/Touchable'
import css from '../../styles/css'
import LAYOUT from '../../styles/LayoutConstants'

const defaultBarcodeWidth = (LAYOUT.WINDOW_WIDTH / 280)
const largeBarcodeWidth = (LAYOUT.WINDOW_HEIGHT / 280)

const StudentIDCard = ({ data, barcodeModalVisible, toggleModal, waitingData }) => (
	<Card id="studentID" title="Student ID">
		{ !data ? (
			<LoadingIndicator />
		) : (
			<View style={css.sid_container}>
				<View style={css.sid_left}>
					<Image
						resizeMode="cover"
						style={css.sid_photo}
						source={{ uri: 'https://facebook.github.io/react-native/docs/assets/favicon.png' }}
					/>
					<Text style={css.sid_affiliation}>
						student
					</Text>
				</View>
				<View style={css.sid_right}>
					<Text style={css.sid_name}>
						John Smith
					</Text>
					<Text style={css.sid_college}>
						{data.College}
					</Text>
					<Text style={css.sid_major}>
						{data.Primary_Major}
					</Text>
					<View style={css.sid_barcode}>
						<Touchable onPress={toggleModal}>
							<Text style={css.sid_barcode_tip}>
								(Tap for easier scanning)
							</Text>
							<View style={css.sid_barcode_inner}>
								<Barcode
									format="codabar"
									value="12345678901234"
									width={defaultBarcodeWidth}
									height={defaultBarcodeWidth * 25}
								/>
							</View>
							<Text style={css.sid_barcode_id}>
								12345678901234
							</Text>
						</Touchable>
					</View>
					<Modal
						style={css.sid_modal}
						isVisible={barcodeModalVisible}
						backdropOpacity={0.3}
					>
						<View style={css.sid_modal_close}>
							<Touchable onPress={toggleModal}>
								<Text style={css.sid_modal_close_text}>Close</Text>
							</Touchable>
						</View>

						<View style={css.sid_modal_barcode}>
							<Barcode
								format="codabar"
								value="12345678901234"
								height={largeBarcodeWidth * 25}
								width={largeBarcodeWidth}
							/>
							<Text style={css.sid_modal_barcode_id}>
								12345678901234
							</Text>
						</View>
					</Modal>
				</View>
			</View>
		)}
	</Card>
)

const LoadingIndicator = () => (
	<View style={css.cc_loadingContainer}>
		<ActivityIndicator size="large" />
	</View>
)

export default StudentIDCard
