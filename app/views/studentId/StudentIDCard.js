import React from 'react'
import { View, Text, ActivityIndicator } from 'react-native'
import Barcode from 'react-native-barcode-builder'
import Modal from 'react-native-modal'
import MCIcon from 'react-native-vector-icons/MaterialCommunityIcons'
import AvatarIcon from 'react-native-vector-icons/Entypo'
import Card from '../common/Card'
import Touchable from '../common/Touchable'
import css from '../../styles/css'
import LAYOUT from '../../styles/LayoutConstants'
import SafeImage from '../common/SafeImage'

const defaultBarcodeWidth = (LAYOUT.WINDOW_WIDTH / 280)
const largeBarcodeWidth = (LAYOUT.WINDOW_HEIGHT / 280)

const StudentIDCard = ({
	studentProfile,
	barcodeModalVisible,
	toggleModal,
	waitingData,
	error,
	studentProfileRequestStatus,
	studentNameRequestStatus,
	studentPhotoRequestStatus,
	studentNameRequestError,
	studentPhotoRequestError,
	studentProfileRequestError
}) => {
	if (studentProfile.image.data && studentProfile.profile.data && studentProfile.name.data && studentProfile.barcode.data) {
		return (
			<Card id="studentId" title="Student ID">
				<View style={css.sid_container}>
					{loadImage(studentProfile.image.data.photo_url)}
					<View style={css.sid_right}>
						<Text style={css.sid_name}>
							{studentProfile.name.data.first_name + ' ' + studentProfile.name.data.last_name}
						</Text>
						<Text style={css.sid_college}>
							{studentProfile.profile.data.College_Current}
						</Text>
						<Text style={css.sid_major}>
							{studentProfile.profile.data.UG_Primary_Major_Current ? studentProfile.profile.data.UG_Primary_Major_Current : studentProfile.profile.data.Graduate_Primary_Major_Current }
						</Text>
						<View style={css.sid_barcode}>
							<Touchable onPress={toggleModal}>
								<Text style={css.sid_barcode_tip}>
									(Tap for easier scanning)
								</Text>
								<View style={css.sid_barcode_inner}>
									<Barcode
										format="codabar"
										value={studentProfile.barcode.data.barCode}
										width={defaultBarcodeWidth}
										height={defaultBarcodeWidth * 25}
									/>
								</View>
								<Text style={css.sid_barcode_id}>
									{studentProfile.barcode.data.barCode}
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
									value={studentProfile.barcode.data.barCode}
									height={largeBarcodeWidth * 25}
									width={largeBarcodeWidth}
								/>
								<Text style={css.sid_modal_barcode_id}>
									{studentProfile.barcode.data.barCode}
								</Text>
							</View>
						</Modal>
					</View>
					<Modal
						style={css.sid_modal}
						isVisible={barcodeModalVisible}
						backdropOpacity={0.3}
					>
						<Touchable
							style={css.sid_modal_close}
							onPress={toggleModal}
						>
							<MCIcon
								size={36}
								name="close-circle-outline"
								style={css.sid_modal_close_icon}
							/>
						</Touchable>

						<View style={css.sid_modal_barcode}>
							<Barcode
								format="codabar"
								value={studentProfile.barcode.data.barCode}
								height={largeBarcodeWidth * 25}
								width={largeBarcodeWidth}
							/>
							<Text style={css.sid_modal_barcode_id}>
								{studentProfile.barcode.data.barCode}
							</Text>
						</View>
					</Modal>
				</View>
			</Card>
		)
	} else {
		return <LoadingCard />
	}
}

const LoadingCard = () => (
	<Card id="studentId" title="Student ID">
		<View style={css.cc_loadingContainer}>
			<ActivityIndicator size="large" />
		</View>
	</Card>
)

const avatarIcon = () => (
	<View style={css.sid_avatar_icon_container}>
		<AvatarIcon
			size={55}
			name="user"
			style={css.sid_avatar_icon}
		/>
	</View>
)

const loadImage = photoUrl => (
	<View style={css.sid_left}>
		<SafeImage
			source={{ uri: photoUrl }}
			style={css.sid_photo}
			onFailure={avatarIcon()}
			resizeMode="contain"
		/>
		<Text style={css.sid_affiliation}>
			student
		</Text>
	</View>
)


export default StudentIDCard
