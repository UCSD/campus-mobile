import React from 'react'
import {
	View,
	Text,
	Image,
	ActivityIndicator
} from 'react-native'

import Card from '../common/Card'
import css from '../../styles/css'
import COLOR from '../../styles/ColorConstants'

const StudentIDCard = ({ data, waitingData }) => {
	if (data) {
		return (
			<Card id="studentID" title="Student ID">
				<View>
					<View style={{ flexDirection: 'row' }}>
						<View style={{ padding: 3 }}>
							<Image
								resizeMode="center"
								style={{ width: 100, height: 100 }}
								source={{ uri: 'https://facebook.github.io/react-native/docs/assets/favicon.png' }}
							/>
							<Text style={{ textAlign: 'center', fontSize: 15 }}>
								{'student'}
							</Text>
						</View>
						<View style={{ paddingLeft: 10 }}>
							<Text style={{ color: COLOR.VDGREY2, fontSize: 17, textAlign: 'left', padding: 2 }}>
								{'Jeremy Wiles'}
							</Text>
							<Text style={{ color: COLOR.DGREY, fontSize: 17, textAlign: 'left', padding: 2 }}>
								{data.College}

							</Text>
							<Text style={{ color: COLOR.VDGREY2, fontSize: 15, textAlign: 'left', padding: 2 }}>
								{data.Primary_Major}
							</Text>
						</View>
					</View>
				</View>
			</Card>
		)
	} else {
		return (
			<LoadingIndicator />
		)
	}
}

const LoadingIndicator = () => (
	<Card id="studentID" title="Student ID">
		<View style={css.cc_loadingContainer}>
			<ActivityIndicator size="large" />
		</View>
	</Card>
)

export default StudentIDCard
