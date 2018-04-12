/*  Master Stylesheet

	Section List
	------------------------------
	100 - Main
		101 - Containers
		102 - Navigator
		103 - Tab Bar

	200 - Common
		201 - DataList
		202 - Buttons

	300 - Cards
		301 - Dining Card
		302 - Survey Card

	400 - Views
		401 - Surf Report
		402 - Dining Detail
		403 - Dining Nutrition
		404 - Event & News
		405 - Special Events
		406 - Feedback
		407 - Preferences View
		408 - Links View
		409 - Map Search
		410 - Search Results

	500 - Misc
*/
import { StyleSheet } from 'react-native'

import { platformAndroid, deviceIphoneX, round } from '../util/general'
import { COLOR } from './ColorConstants'
import { LAYOUT } from './LayoutConstants'

const css = StyleSheet.create({
	/**
	 *  100 - Main
	 */
	// 101 - Containers
	main_container: { flex: 1 },
	main_full: { backgroundColor: COLOR.WHITE, paddingBottom: deviceIphoneX() ? LAYOUT.NAVIGATOR_HEIGHT : 0 },
	scroll_default: { backgroundColor: COLOR.WHITE },
	card_container: { backgroundColor: COLOR.WHITE, margin: 6 },
	main_full_lgrey: { flexGrow: 1, backgroundColor: COLOR.LGREY }, // special events
	// 102 - Navigator
	nav: { backgroundColor: COLOR.PRIMARY, height: LAYOUT.NAVIGATOR_HEIGHT, marginTop: deviceIphoneX() ? -13 : 0 },
	navTitle: { flex: 1, fontSize: 24, fontWeight: '300', textAlign: 'center', alignSelf: 'center', marginTop: deviceIphoneX() ? 0 : -3 },
	navCampusLogoTitle: { flex: 1, resizeMode: 'contain', height: 26, alignSelf: 'center', marginTop: platformAndroid() ? 6 : 0 },
	navButtonTextIOS: { color: COLOR.WHITE, fontWeight: '300', fontSize: 18, height: 24 },
	navButtonTextAndroid: { color: COLOR.WHITE, marginTop: -8, fontWeight: '300', fontSize: 18 },
	// 103 - Tab Bar
	tabBarIOS: { backgroundColor: COLOR.WHITE, height: LAYOUT.TAB_BAR_HEIGHT },
	tabBarAndroid: { backgroundColor: COLOR.WHITE, height: LAYOUT.TAB_BAR_HEIGHT },
	tabContainer: { paddingTop: deviceIphoneX() ? 17 : 0 },
	tabContainerBottom: { borderBottomColor: COLOR.PRIMARY },
	tabIcon: { color: COLOR.DMGREY, alignSelf: 'center', backgroundColor: COLOR.TRANSPARENT, opacity: 0.95, width: 24, height: 24, overflow: 'hidden' },
	tabIconUser: { color: COLOR.WHITE, alignSelf: 'center', backgroundColor: COLOR.DMGREY, opacity: 0.95, width: 24, height: 24, overflow: 'hidden' },
	tabIconUserOutline: { borderColor: COLOR.DMGREY, alignSelf: 'center', overflow: 'hidden', borderRadius: 24, borderWidth: 1 },

	/**
	 *  200 - Common
	 */
	// 201 - DataList
	DataList_card_list: { padding: 8 },
	DataList_full_list: { padding: 8 },
	// 202 - DataItem
	dataitem_descContainer: { flex: 1 },
	dataitem_descText: { color: COLOR.VDGREY },
	dataitem_touchableRow: { paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: COLOR.MGREY, },
	dataitem_titleText: { fontSize: 17 },
	dataitem_listInfoContainer: { flexDirection: 'row', paddingVertical: 8 },
	dataitem_dateText: { color: COLOR.PRIMARY, paddingTop: 8 },
	dataitem_image: { width: 120, height: 70, marginLeft: 10, borderWidth: 1, borderColor: COLOR.LGREY },
	// 203 - Buttons
	button_primary: { justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR.PRIMARY, borderRadius: 3, marginTop: 20, padding: 10 },
	button_primary_text: { fontSize: 16, color: COLOR.WHITE },
	share_button: { justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR.MGREY, borderRadius: 3, marginTop: 20, padding: 10 },
	share_button_text: { fontSize: 16 },


	/**
	 *  300 - Cards
	 */
	// 301 - Dining Card
	dl_row: { flexDirection: 'row', padding: 10, borderBottomWidth: 1, borderBottomColor: COLOR.MGREY },
	dl_row_container_left: { flex: 4, flexDirection: 'column', justifyContent: 'flex-start', paddingRight: 8 },
	dl_row_container_right: { flex: 1, alignItems: 'center', justifyContent: 'flex-end' },
	dl_title_row: { flexDirection: 'column', justifyContent: 'flex-start', alignItems: 'flex-start', flexWrap: 'wrap' },
	dl_title_text: { fontSize: 20, color: COLOR.PRIMARY },
	dl_status_row: { flex: 1, flexDirection: 'row', justifyContent: 'flex-start', alignItems: 'center', paddingTop: 8 },
	dl_hours_row: { flexDirection: 'row', justifyContent: 'flex-start', alignItems: 'center', paddingTop: 8 },
	dl_hours_text: { flexGrow: 1, paddingRight: 8 },
	dl_status_icon: { paddingRight: 8 },
	dl_status_text: { fontWeight: '700', paddingRight: 8 },
	dl_status_disclaimer: { color: COLOR.DORANGE },
	dl_status_soon_text: { paddingRight: 8 },
	dl_dir_traveltype_container: { flex: 1, flexDirection: 'column', alignItems: 'center', justifyContent: 'center' },
	dl_dir_eta: { color: COLOR.PRIMARY, fontSize: 11, fontWeight: '600' },
	// 302 - Survey Card
	card_main: { borderWidth: 1, borderRadius: 2, borderColor: COLOR.COLOR_MGREY, backgroundColor: COLOR.WHITE, margin: 6, alignItems: 'flex-start', justifyContent: 'center', overflow: 'hidden' },
	card_row_container: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', padding: 8, paddingBottom: 0 },
	card_footer_container: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', padding: 8 },
	card_button_container: { justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR.WHITE, },
	card_button_text: { fontSize: 20, alignItems: 'center', textAlign: 'center' },
	card_text_container: { justifyContent: 'center', alignItems: 'center', width: LAYOUT.MAX_CARD_WIDTH, padding: 8, borderBottomWidth: 1, borderBottomColor: COLOR.COLOR_MGREY },

	/**
	 *  400 - Views
	 */
	// 401 - Surf Report
	sr_headerImage: { width: LAYOUT.WINDOW_WIDTH, height: round(LAYOUT.WINDOW_WIDTH * 0.361) },
	sr_container: { paddingHorizontal: 10, paddingTop: 10 },
	sr_beach_list: { marginTop: 20 },
	sr_surf_row: { marginBottom: 15 },
	sr_title: { fontSize: 22, fontWeight: '400', color: COLOR.PRIMARY },
	sr_desc: { fontSize: 16, marginTop: 5 },
	sr_beach_name: { fontSize: 18 },
	sr_beach_surf: { fontSize: 16, paddingTop: 4, paddingLeft: 8 },


	// 402 - Dining Detail
	dd_description_container: { padding: 10 },
	dd_description_nametext: { fontSize: 26, color: COLOR.PRIMARY },
	dd_description_text: { paddingTop: 4 },
	dd_description_subtext: { paddingTop: 8, color: COLOR.BLACK, fontWeight: '700' },
	dd_hours_text_container: { flexDirection: 'row', alignItems: 'center', color: COLOR.BLACK },
	dd_hours_text_disclaimer: { color: COLOR.DORANGE, paddingVertical: 8 },
	dd_hours_row: { flexDirection: 'row', paddingBottom: 8, flexWrap: 'wrap', alignItems: 'flex-start' },
	dd_hours_text_title: { width: '35%', paddingRight: 8, color: COLOR.BLACK },
	dd_status_icon: { paddingLeft: 8 },
	dd_special_hours_text_title: { color: COLOR.BLACK, width: '50%', paddingRight: 8 },
	dd_hours_text_hours: { flexGrow: 1, color: COLOR.BLACK },
	dd_hours_text_special_hours: { paddingBottom: 8, color: COLOR.BLACK },
	dd_images_scrollview: { height: 140 },
	dd_images_image: { width: 140, height: 140, borderRadius: 5, marginHorizontal: 7 },
	dd_directions_button_container: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', borderBottomWidth: 1, borderBottomColor: COLOR.MGREY, margin: 6, padding: 6 },
	dd_directions_text: { flex: 5, fontSize: 22, color: COLOR.PRIMARY },
	dd_directions_icon_container: { flex: 1, flexDirection: 'column', alignItems: 'center', justifyContent: 'center' },
	dd_directions_distance_text: { color: COLOR.PRIMARY, fontSize: 11, fontWeight: '600' },
	dd_menu_link_container: { justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR.PRIMARY, borderRadius: 3, margin: 20, padding: 10 },
	dd_menu_container: { marginHorizontal: 8 },
	dd_menu_link_text: { fontSize: 16, color: COLOR.WHITE },
	dd_menu_food_type: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', marginVertical: 8 },
	dd_menu_meal_type: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', borderTopWidth: 1, borderTopColor: COLOR.MGREY, },
	dd_menu_meal_type_text: { fontSize: 20, color: COLOR.DGREY, },
	dd_menu_meal_type_text_active: { fontSize: 20, color: COLOR.PRIMARY, },
	dd_menu_filter_button: { paddingVertical: 8, paddingHorizontal: 14, fontSize: 14, color: COLOR.DGREY, borderWidth: 1, borderColor: COLOR.DGREY, borderRadius: 3, backgroundColor: COLOR.MGREY, textAlign: 'center', marginHorizontal: 8 },
	dd_menu_filter_button_active: { paddingVertical: 8, paddingHorizontal: 14, fontSize: 14, color: COLOR.WHITE, borderWidth: 1, borderColor: COLOR.DGREY, borderRadius: 3, backgroundColor: COLOR.PRIMARY, textAlign: 'center', marginHorizontal: 8, overflow: 'hidden' },
	dd_menu_circle: { borderWidth: 1, borderColor: COLOR.MGREY, borderRadius: 8, width: 16, height: 16, backgroundColor: COLOR.MGREY, marginRight: 5 },
	dd_menu_circle_active: { borderWidth: 1, borderColor: COLOR.MGREY, borderRadius: 8, width: 16, height: 16, backgroundColor: COLOR.PRIMARY, marginRight: 5 },
	dd_menu_row: { flexDirection: 'row', paddingBottom: 8 },
	dd_menu_item_name_text: { fontSize: 15, color: COLOR.PRIMARY },
	dd_menu_item_price_text: { color: COLOR.BLACK, paddingLeft: 26, marginLeft: 30 },
	dd_menu_meal_button: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', height: 40, },
	dd_description_po: { color: COLOR.BLACK },
	// 403 - Dining Nutrition
	dn_container: { paddingHorizontal: 10, paddingTop: 10 },
	dn_title: { fontSize: 26, color: COLOR.PRIMARY },
	dn_market: { fontSize: 16 },
	dn_nf_container: { borderWidth: 2, borderColor: COLOR.BLACK, padding: 3, marginTop: 10 },
	dn_header: { fontSize: 42, fontWeight: '700', backgroundColor: COLOR.TRANSPARENT },
	dn_servingsize: { fontSize: 18 },
	dn_nf_bold: { fontWeight: '700' },
	dn_amountperserving: { fontSize: 14, fontWeight: '700' },
	dn_dv: { fontSize: 14, fontWeight: '700', textAlign: 'right', paddingVertical: 2 },
	dn_font: { fontSize: 18 },
	dn_disclaimer_font: { fontSize: 14 },
	dn_row_main: { flex: 5, flexDirection: 'row', borderTopWidth: 1, borderTopColor: COLOR.DMGREY, paddingVertical: 2 },
	dn_row_sub: { flex: 5, flexDirection: 'row', borderTopWidth: 1, borderTopColor: COLOR.DMGREY, paddingVertical: 2, paddingLeft: 20 },
	dn_percent: { flex: 1, fontSize: 18, fontWeight: '700', textAlign: 'right' },
	dn_dv_amountperserving: { fontSize: 13 },
	dn_topborder1: { borderTopWidth: 8, borderTopColor: COLOR.BLACK, paddingVertical: 2, marginTop: 2 },
	dn_topborder2: { borderTopWidth: 4, borderTopColor: COLOR.BLACK },
	dn_info_container: { paddingTop: 10 },
	dn_bold: { fontWeight: '700' },

	// 404 - Events & News
	eventdetail_readmore_container: { justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR.PRIMARY, borderRadius: 3, marginTop: 20, padding: 10 },
	eventdetail_readmore_text: { fontSize: 16, color: COLOR.WHITE },
	media_detail_container: { width: LAYOUT.WINDOW_WIDTH, paddingHorizontal: 12, paddingVertical: 14 },
	media_detail_image: { width: LAYOUT.WINDOW_WIDTH, height: 200 },
	media_detail_title: { fontSize: 22, color: COLOR.PRIMARY },
	media_detail_dateText: { color: COLOR.PRIMARY, paddingTop: 14 },
	media_detail_descText: { lineHeight: 18, color: COLOR.BLACK, fontSize: 14, paddingTop: 14 },
	media_detail_locationText: { fontSize: 16, color: COLOR.DGREY },
	// 405 - Special Events
	specialevents_filter: { backgroundColor: COLOR.WHITE, paddingBottom: deviceIphoneX() ? (LAYOUT.NAVIGATOR_HEIGHT + 60) : 60 },
	specialevents_filter_itemrow: { flexDirection: 'row', alignItems: 'center', backgroundColor: COLOR.WHITE, borderBottomWidth: 1, borderBottomColor: COLOR.LGREY, padding: 12 },
	specialevents_filter_applybutton: { position: 'absolute', width: LAYOUT.WINDOW_WIDTH - 20, bottom: deviceIphoneX() ? LAYOUT.NAVIGATOR_HEIGHT : 10, left: 10, padding: 10, justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR.PRIMARY, borderRadius: 3, opacity: 0.95 },
	specialevents_filter_applybutton_text: { fontSize: 16, color: COLOR.WHITE },
	// 406 - Feedback
	feedback_container: { flex: 1, flexDirection: 'column', marginHorizontal: 8, marginTop: 8, marginBottom: 8 },
	feedback_label: { flexWrap: 'wrap', fontSize: 18, paddingBottom: 16, lineHeight: 24 },
	feedback_comments_text_container: { flexDirection: 'row', borderColor: COLOR.MGREY, borderBottomWidth: 1, marginBottom: 8, backgroundColor: 'white' },
	feedback_email_text_container: { borderColor: COLOR.MGREY, borderBottomWidth: 1, marginBottom: 8 },
	feedback_text_input: { flex: 1, backgroundColor: COLOR.WHITE, fontSize: 18, alignItems: 'center', padding: 8 },
	feedback_submit_container: { justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR.PRIMARY, borderRadius: 3, padding: 10 },
	feedback_submit_text: { fontSize: 16, color: 'white' },
	feedback_submitting_container: { flex: 1, flexDirection: 'column', padding: 16, alignItems: 'center', justifyContent: 'center' },
	feedback_loading_icon: { paddingBottom: 16 },
	feedback_submitting_text: { fontSize: 18, textAlign: 'center' },
	// 407 - Preferences View (User Settings)
	UserAccount_text: { flex: 1, fontSize: 18 },
	UserAccount_icon: { flex: 1 },
	UserAccount_infoContainer: { flexGrow: 1, flexDirection: 'row', margin: 7 },
	UserAccount_loginContainer: { flexGrow: 1, margin: 7 },
	UserAccount_input: { flexGrow: 1, height: 50 },
	UserAccount_spacedRow: { flexDirection: 'row', justifyContent: 'space-between' },
	UserAccount_accountText: { textAlign: 'center', fontSize: 16, color: COLOR.DGREY },
	UserAccount_forgotButton: { flex: 1, justifyContent: 'center', alignItems: 'center', borderRadius: 3, padding: 10, },
	UserAccount_loginButton: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR.PRIMARY, borderRadius: 3, padding: 10, },
	UserAccount_forgotText: { fontSize: 16, color: COLOR.PRIMARY },
	UserAccount_loginText: { fontSize: 16, color: COLOR.WHITE },
	// 408 - Links View
	links_row_container: { borderBottomWidth: 1, borderBottomColor: COLOR.MGREY, paddingBottom: 8, marginBottom: 8 },
	links_row: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center' },
	links_icon: { height: 42, width: 38 },
	links_icon_fa: { padding: 8, color: COLOR.PRIMARY },
	links_name: { flexGrow: 5, color: COLOR.BLACK, fontSize: 16, paddingHorizontal: 8 },
	links_arrow_icon: { color: COLOR.DGREY },
	// 409 - Map Search
	map_nogoogleplay: { padding: 16 },
	// 410 - Search Results
	destinationcard_marker_label: { flex: 2, fontSize: 18, paddingLeft: 8, paddingTop: 0, color: COLOR.PRIMARY, justifyContent: 'center' },
	destinationcard_marker_dist_label: { flex: 1, textAlign: 'right', fontSize: 18, paddingLeft: 8, paddingTop: 0, color: COLOR.PRIMARY, justifyContent: 'center' },

	/**
	 *  500 - Misc
	 */
	bold: { fontWeight: '700' },
	flex: { flex: 1 },
})

module.exports = css
