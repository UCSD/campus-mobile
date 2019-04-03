import React from 'react'
import {
	View,
	Text,
	Image,
	ActivityIndicator
} from 'react-native'
import Barcode from 'react-native-barcode-builder'
import Modal from 'react-native-modal'

import Card from '../common/Card'
import Touchable from '../common/Touchable'
import css from '../../styles/css'
import COLOR from '../../styles/ColorConstants'
import LAYOUT from '../../styles/LayoutConstants'

const StudentIDCard = ({ data, barcodeModalVisible, toggleModal, waitingData }) => {
	const defaultBarcodeWidth = (LAYOUT.WINDOW_WIDTH / 280)
	const largeBarcodeWidth = (LAYOUT.WINDOW_HEIGHT / 280)

	return (
		<Card id="studentID" title="Student ID">
			{ data ? (
				<View style={{ flexDirection: 'row', margin: 12 }}>
					<View style={{ flex: 1 }}>
						<Image
							resizeMode="cover"
							style={{ height: 80, borderWidth: 1 }}
							source={{ uri: 'https://facebook.github.io/react-native/docs/assets/favicon.png' }}
						/>
						<Text style={{ textAlign: 'center', fontSize: 15, paddingTop: 8 }}>
							student
						</Text>
					</View>
					<View style={{ flex: 3, marginLeft: 16 }}>
						<Text style={{ fontSize: 16 }}>
							John Smith
						</Text>
						<Text style={{ color: COLOR.DGREY, fontSize: 16, paddingTop: 2 }}>
							{data.College}
						</Text>
						<Text style={{ fontSize: 16, paddingTop: 2 }}>
							{data.Primary_Major}
						</Text>

						<View style={{ flexGrow: 1, marginTop: 8, justifyContent: 'center' }}>
							<Touchable onPress={toggleModal}>
								<Text style={{ textAlign: 'center', color: COLOR.DGREY, fontSize: 10, zIndex: 2 }}>
									(Tap for easier scanning)
								</Text>
								<View style={{ marginTop: -10 }}>
									<Barcode
										format="codabar"
										value="12345678901234"
										width={defaultBarcodeWidth}
										height={40}
									/>
								</View>
								<Text style={{ textAlign: 'center', fontSize: 14, zIndex: 2, marginTop: -10, letterSpacing: 4 }}>
									12345678901234
								</Text>
							</Touchable>
						</View>

						<Modal
							style={{ margin: 40, backgroundColor: COLOR.WHITE }}
							isVisible={barcodeModalVisible}
							backdropOpacity={0.4}
						>
							<View style={{ position: 'absolute', bottom: 32, right: 16, transform: [{ rotate: '90deg' }], fontSize: 16 }}>
								<Touchable onPress={toggleModal}>
									<Text style={{ textAlign: 'right', padding: 8, color: COLOR.PRIMARY }}>Close</Text>
								</Touchable>
							</View>

							<View style={{ justifyContent: 'center', transform: [{ rotate: '90deg' }] }}>
								<Barcode
									format="codabar"
									value="12345678901234"
									height={60}
									width={largeBarcodeWidth}
								/>
								<Text style={{ textAlign: 'center', fontSize: 20, zIndex: 2, letterSpacing: 4 }}>
									12345678901234
								</Text>
							</View>
						</Modal>

					</View>
				</View>
			) : (
				<LoadingIndicator />
			)}
		</Card>
	)
}

const LoadingIndicator = () => (
	<View style={css.cc_loadingContainer}>
		<ActivityIndicator size="large" />
	</View>
)

export default StudentIDCard
