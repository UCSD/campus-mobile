/*
	Master Stylesheet

	Section List
	------------------------------------------
	100 - Navigation
		101 - Navigator
		102 - Tab Bar

	200 - Primary Containers
	
	300 - Cards
		301 - Card Container
		302 - Weather Card
		303 - Shuttle Card
		304 - Dining Card
		305 - Events & News Cards
		306 - Links Card
	
	400 - Views
		401 - Surf Report
		402 - Shuttle Stop
		403 - Dining List
		404 - Dining Detail
		405 - Welcome Week
		406 - Event & News Detail
		407 - WebView
		408 - Feedback
		409 - Preferences View
		410 - Links View
	
	500 - Modules
		501 - Map Search
		502 - Search Results
		503 - LocationRequiredContent
	
	900 - Misc
*/

import React from 'react';
import { StyleSheet, Dimensions, StatusBar } from 'react-native';

var general = require('../util/general');

var windowSize = Dimensions.get('window');
var windowWidth = windowSize.width;
var windowHeight = windowSize.height;

var maxCardWidth = windowWidth - 2 - 12;

// IOS / Android Custom
var NavigatorIOSHeight = 58,
	NavigatorAndroidHeight = 44,
	StatusBarAndroidHeight = general.platformAndroid() ? StatusBar.currentHeight : 0,
	TabBarHeight = 40;

var IOSMarginTop = NavigatorIOSHeight,
	AndroidMarginTop = NavigatorAndroidHeight + TabBarHeight,
	IOSMarginBottom = TabBarHeight,
	AndroidMarginBottom = 0;

// Campus Branding
var campus_primary = '#182B49';

var css = StyleSheet.create({


	/********************************************
	 *  100 - Navigation
	 ********************************************/
	// 101 - Navigator
	navIOS: { backgroundColor: 'rgba(24,43,73,1)', height: NavigatorIOSHeight },
	navAndroid: { backgroundColor: 'rgba(24,43,73,1)', height: NavigatorAndroidHeight },
	navIOSTitle: { color: '#FFF', fontSize: 24, marginTop: -8, fontWeight: '300' },
	navAndroidTitle: { color: '#FFF', fontSize: 24, marginTop: -8, fontWeight: '300' },
	navCampusLogoTitle: { resizeMode: 'contain', height: 26, marginTop: general.platformIOS() ? 26 : 12, alignSelf: 'center' },
	navIOSIconStyle: { tintColor:'#FFF', marginTop: -2 },
	navBackButtonTextIOS: { color: '#FFF', marginTop: -2, fontWeight: '300' },
	navAndroidIconStyle: { tintColor:'#FFF', marginTop: -6 },
	navBackButtonTextAndroid: { color: '#FFF', marginTop: -6, fontWeight: '300' },
	// 102 - Tab Bar
	tabBarIOS: { borderTopWidth: 1, borderColor: '#DADADA', backgroundColor: '#FFF', height: TabBarHeight },
	tabBarAndroid: { top: NavigatorAndroidHeight, borderBottomWidth: 1, borderColor: '#DADADA', backgroundColor: '#FFF', height: TabBarHeight },
	tabContainer: { width: 70, paddingVertical: 8 },
	tabContainerBottom: { borderBottomColor: campus_primary },
	tabIcon: { color: '#999', alignSelf: 'center', backgroundColor: 'rgba(0,0,0,0)', opacity: .95 },


	/********************************************
	 *  200 - Primary Containers
	 ********************************************/
	main_container: { flexGrow: 1, backgroundColor: '#EAEAEA', marginTop: general.platformIOS() ? IOSMarginTop : AndroidMarginTop, marginBottom: general.platformIOS() ? IOSMarginBottom : AndroidMarginBottom },
	view_all_container: { backgroundColor: '#FFF', paddingHorizontal: 12, marginTop: general.platformIOS() ? IOSMarginTop : AndroidMarginTop, marginBottom: general.platformIOS() ? IOSMarginBottom : AndroidMarginBottom },
	view_container: { backgroundColor: '#FFF', marginTop: general.platformIOS() ? IOSMarginTop : AndroidMarginTop, marginBottom: general.platformIOS() ? IOSMarginBottom : AndroidMarginBottom },
	listview_main: { marginTop: general.platformIOS() ? IOSMarginTop : AndroidMarginTop, },
	view_default: { paddingHorizontal: 8 },
	scroll_default: { alignItems: 'center' },


	/********************************************
	 *  300 - Cards
	 ********************************************/
	 // 301 - Card Container
	card_main: { borderWidth: 1, borderRadius: 2, borderColor: '#DDD', backgroundColor: '#F9F9F9', margin: 6, alignItems: 'flex-start', justifyContent: 'center', overflow: 'hidden' },
	card_plain: { margin: 6, alignItems: 'center', justifyContent: 'center' },
	card_special_events: {  },
	card_title_container: { alignItems: 'center', width: maxCardWidth, padding: 8, borderBottomWidth: 1, borderBottomColor: '#DDD' },
	card_row_container: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', padding: 8, paddingBottom: 0 },
	card_footer_container: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', padding: 8 },
	card_button_container: { justifyContent: 'center', alignItems: 'center', backgroundColor: '#F9F9F9', },
	card_button_text: { fontSize: 20, alignItems: 'center', textAlign: 'center' },
	card_text_container: { justifyContent: 'center', alignItems: 'center', width: maxCardWidth, padding: 8, borderBottomWidth: 1, borderBottomColor: '#DDD' },
	card_content_full_width: { width: maxCardWidth, overflow: 'hidden' },
	card_menu: { flexDirection: 'row', justifyContent: 'flex-end', },
	card_hide_option: { margin: 10, fontSize: 16 },
	card_menu_trigger: { paddingTop: 9, paddingBottom: 6, paddingLeft: 12, paddingRight: 10, color: '#747678', },
	card_container_main: { flexDirection: 'row', borderBottomWidth: 1, borderBottomColor: '#DDD', alignSelf: 'stretch' },
	card_title_main: { width: maxCardWidth, flexDirection: 'row', borderBottomWidth: 1, borderColor: '#DDD', backgroundColor: '#F9F9F9', },
	card_title_text: { flex: 1, fontSize: 26, color: '#747678', paddingLeft: 10, paddingVertical: 6 },
	card_row_center: { alignItems: 'center', justifyContent: 'center', width: maxCardWidth, overflow: 'hidden' },
	card_loader: { height: 368 },
	card_more: { alignItems: 'center', justifyContent: 'center', paddingHorizontal: 4, paddingTop: 8, paddingBottom: 4 },
	card_more_label: { fontSize: 20, color: campus_primary, fontWeight: '300' },

	// 302 - Weather Card
	weathercard_more: { justifyContent: 'center', width: windowWidth - 30, padding: 10, fontSize: 24, fontWeight: '500', color: campus_primary },
	weathercard_border: { borderTopWidth: 1, borderTopColor: '#CCC', width: maxCardWidth },
	weatherccard_loading_height: { height: 270 },
	wc_main: {},
	wc_toprow: { flexDirection: 'row', borderBottomWidth: 1, borderColor: '#EEE', justifyContent: 'center', alignItems: 'center', width: maxCardWidth, paddingHorizontal: 14 },
	wc_toprow_left: { flex: 4 },
	wc_current_temp: { fontSize: 22, fontWeight: '300' },
	wc_current_summary: { fontSize: 15, color: '#444', paddingTop: 10, fontWeight: '300' },
	wc_toprow_right: { flex: 1 },
	wc_toprow_icon: { width: 68, height: 68 },
	wc_botrow: { flexDirection: 'row', padding: 20 },
	wc_botrow_col: { flex: 1, flexDirection: 'column', justifyContent: 'center', alignItems: 'center' },
	wf_dayofweek: { fontSize: 14, fontWeight: '300', color: '#444', paddingBottom: 10},
	wf_icon: { height: 33, width: 33 },
	wf_tempMax: { fontSize: 14, fontWeight: '300', color: '#000', paddingTop: 10 },
	wf_tempMin: { fontSize: 14, fontWeight: '300', color: '#666', paddingTop: 10 },
	wc_surfreport_more: { fontSize: 20, fontWeight: '300', color: campus_primary, paddingHorizontal: 14, paddingVertical: 10 },

	// 303 - Shuttle Card
	shuttle_card_row: { width: maxCardWidth - 50, borderBottomWidth: 1, borderBottomColor: '#DDD' },
	shuttle_card_err_row: { alignItems: 'center', justifyContent: 'center', width: maxCardWidth, },
	shuttle_card_row_center: { alignItems: 'center', justifyContent: 'center', width: maxCardWidth, },
	shuttle_card_loader: { height: 350 },
	shuttle_card_row_border: { borderTopWidth: 1, borderTopColor: '#DDD' },
	shuttle_card_row_top: { flexDirection: 'row', alignItems: 'stretch', justifyContent: 'center', marginVertical: 20, height: 83 },
	shuttle_card_rt_1: { flexGrow: 1 },
	shuttle_card_rt_2: { borderRadius: 50, width: 83, justifyContent: 'center', overflow: 'hidden' },
	shuttle_card_rt_2_label: { textAlign: 'center', color: '#222', fontWeight: '600', fontSize: 48, backgroundColor: 'rgba(0,0,0,0)' },
	shuttle_card_rt_3: { flexGrow: 3, justifyContent: 'center' },
	shuttle_card_rt_3_label: { textAlign: 'center', color: '#8f9092', fontSize: 30, fontWeight: '300', backgroundColor: 'rgba(0,0,0,0)' },
	shuttle_card_rt_4: { borderRadius: 48, borderWidth: 1, backgroundColor: '#FFF', borderColor: '#CCC', width: 83, justifyContent: 'center' },
	shuttle_card_rt_4_label: { padding: 5, textAlign: 'center', color: '#8f9092', fontWeight: '500', fontSize: 16, backgroundColor: 'rgba(0,0,0,0)' },
	shuttle_card_rt_5: { flexGrow: 1 },
	shuttle_card_row_bot: { alignItems: 'center', paddingBottom: 10, paddingHorizontal: 8 },
	shuttle_card_row_name: { fontSize: 17, color: '#666' },
	shuttle_card_row_arriving: { fontSize: 26, color: '#333' },
	shuttlecard_loading: { marginHorizontal: 40, marginVertical: 156 },
	shuttlecard_loading_fail: { marginHorizontal: 16, marginTop: 40, marginBottom: 60 },
	sc_next_arrivals_text: { fontSize: 20, fontWeight: '300', color: '#222', padding: 8 },
	sc_arrivals_row: { flexDirection: 'row', marginBottom: 8, marginHorizontal: 8, alignItems: 'center', justifyContent: 'flex-start' },
	sc_rt_2: { borderRadius: 18, width: 36, height: 36, justifyContent: 'center', overflow: 'hidden' },
	sc_rt_2_label: { textAlign: 'center', fontWeight: '600', fontSize: 19, backgroundColor: 'rgba(0,0,0,0)' },
	sc_arrivals_row_route_name: { flex: 4.5, fontSize: 17, color: '#666', marginLeft: 10 },
	sc_arrivals_row_eta_text: { flex: 1, fontSize: 17, color: '#333', marginLeft: 10 },

	// 304 - Dining Card
	dining_card: { width: maxCardWidth, padding: 8 },
	dining_card_filters: { flexDirection: 'row', justifyContent: 'center', marginBottom: 6 },
	dining_card_filter_button: { paddingVertical: 8, paddingHorizontal: 14, fontSize: 14, color: '#888', borderWidth: 1, borderColor: '#CCC', borderRadius: 3, backgroundColor: '#EEE', textAlign: 'center', marginHorizontal: 8 },
	dining_card_filter_button_active: { paddingVertical: 8, paddingHorizontal: 14, fontSize: 14, color: '#EEE', borderWidth: 1, borderColor: '#CCC', borderRadius: 3, backgroundColor: campus_primary, textAlign: 'center', marginHorizontal: 8, overflow: 'hidden' },
	dc_locations: { flexDirection: 'column' },
	dc_locations_row: { backgroundColor: '#F9F9F9', flexDirection: 'row', paddingBottom: 10, paddingTop: 10, borderBottomWidth: 1, borderBottomColor: '#DDD' },
	dc_locations_row_left: { flex: 6, justifyContent: 'center' },
	dc_locations_title: { fontSize: 20, color: campus_primary },
	dc_locations_hours: { fontSize: 12, color: '#666', paddingTop: 1 },
	dc_locations_spec_hours: { fontSize: 12, color: '#666', paddingTop: 4 },
	dc_locations_description: { fontSize: 12, color: '#666', paddingTop: 6 },
	dc_locations_row_right: { flex: 1, alignItems: 'center', justifyContent: 'center' },
	dining_card_more: { alignItems: 'center', justifyContent: 'center', paddingHorizontal: 4, paddingTop: 8, paddingBottom: 4, borderTopWidth: 1, borderTopColor: '#DDD' },
	dining_card_more_label: { fontSize: 20, color: campus_primary, fontWeight: '300' },

	// 305 - Events & News Cards
	events_list: { alignSelf: 'stretch', padding: 8 },
	events_list_row: { paddingHorizontal: 0, paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: '#EEE', },
	events_list_title: { fontSize: 17, color: '#000', alignSelf: 'stretch' },
	events_list_info: { flexDirection: 'row', paddingVertical: 8 },
	events_list_info_left: { flex: 1 },
	events_list_image: { width: 120, height: 70, marginLeft: 10, borderWidth: 1, borderColor: '#EEE' },
	events_list_desc: { fontSize: 14, color: '#666' },
	events_list_postdate: { fontSize: 11, color: campus_primary, paddingTop: 8 },
	events_more: { alignItems: 'center', justifyContent: 'center', paddingHorizontal: 4, paddingTop: 8, paddingBottom: 4 },
	events_more_label: { fontSize: 20, color: campus_primary, fontWeight: '300' },
	events_card_container: { flexDirection: 'row', padding: 14, borderBottomWidth: 1, borderBottomColor: '#EEE', alignItems: 'center' },
	events_card_title_container: { flexDirection: 'row', alignItems: 'center', width: maxCardWidth, padding: 8, borderBottomWidth: 1, borderBottomColor: '#DDD' },
	events_card_title: { flex:1, flexWrap: 'wrap', fontSize: 17, color: '#000' },
	events_card_left_container: { flex: 10 },
	events_card_desc: { flexWrap: 'wrap', fontSize: 14, color: '#666', paddingTop: 8 },
	events_card_postdate: { fontSize: 11, color: campus_primary, paddingTop: 8 },
	news_card_image: { width: 130, height: 100, marginRight: 4, marginLeft: 10, borderWidth: 1, borderColor: '#CCC'},
	events_card_image: { width: 130, height: 73, marginRight: 4, marginLeft: 10, borderWidth: 1, borderColor: '#CCC'},
	content_load_err: { padding: 30, fontSize:16, alignSelf: 'center'  },

	// 306 - Links Card
	quicklinks_card: { alignSelf: 'stretch', padding: 8 },
	quicklinks_locations: { flexDirection: 'column' },
	quicklinks_row_container: { borderBottomWidth: 1, backgroundColor: '#F9F9F9', borderBottomColor: '#EEE', paddingVertical: 10 },
	quicklinks_row: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center' },
	quicklinks_icon: { height: 42, width: 38 },
	quicklinks_icon_fa: { padding: 8 },
	quicklinks_name: { flexGrow: 5, color: '#444', fontSize: 16, paddingHorizontal: 8 },


	/********************************************
	 *  400 - Views
	 ********************************************/
	// 401 - Surf Report
	sr_listview: {},
	sr_image: { width: windowWidth, height: round(windowWidth * .361) },
	sr_day_row: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', padding: 10 },
	sr_day_row_border: { borderTopWidth: 1, borderTopColor: '#CCC' },
	sr_day_date_container: { flex: 1, alignItems: 'center', justifyContent: 'center' },
	sr_dayofweek: { fontSize: 19, color: '#000' },
	sr_dayandmonth: { fontSize: 12, color: '#777' },
	sr_day_details_container: { flex: 3, paddingLeft: 10, borderLeftWidth: 1, borderLeftColor: '#DDD' },
	sr_day_details_title: { fontSize: 18, color: '#000' },
	sr_day_details_height: { fontSize: 16, color: '#333', paddingTop: 4 },
	sr_day_details_desc: { fontSize: 13, color: '#777', paddingTop: 4 },
	
	// 402 - Shuttle Stop
	shuttlestop_image: { width: windowWidth, height: round(windowWidth * .533) },
	shuttlestop_name_container: { flexDirection: 'row', alignItems: 'center', width: windowWidth, paddingVertical: 10, paddingHorizontal: 14, backgroundColor: campus_primary },
	shuttlestop_name_text: { flex: 5, color: '#FFF', fontSize: 24, fontWeight: '300' },
	shuttlestop_refresh_container: { flex: 1, alignItems: 'flex-end' },
	shuttlestop_refresh: { width: 26, height: 26 },
	shuttle_stop_arrivals_container: { width: windowWidth, paddingLeft: 20, paddingVertical: 16 },
	shuttle_stop_next_arrivals_text: { fontSize: 20, fontWeight: '300', color: '#222', paddingTop: 8, paddingBottom: 16 },
	shuttle_stop_arrivals_row: { flex: 1, flexDirection: 'row', paddingBottom: 13, alignItems: 'center', justifyContent: 'flex-start' },
	shuttle_stop_rt_2: { borderRadius: 18, width: 36, height: 36, justifyContent: 'center' },
	shuttle_stop_rt_2_label: { textAlign: 'center', fontWeight: '600', fontSize: 19, backgroundColor: 'rgba(0,0,0,0)' },
	shuttle_stop_arrivals_row_route_name: { flex: 2, fontSize: 17, color: '#555', paddingLeft: 10 },
	shuttle_stop_arrivals_row_eta_text: { flex: 1, fontSize: 20, color: '#333', paddingLeft: 16, paddingRight: 16 },
	shuttlestop_loading: { width: 48, height: 48, marginHorizontal: 40, marginVertical: 50 },
	shuttle_stop_map_container: { margin: 1 },
	shuttle_stop_map_text: { fontSize: 20, fontWeight: '300', paddingTop: 16, color: '#222', paddingLeft: 20, paddingBottom: 8 },
	shuttlestop_map: { width: windowWidth, height: round(windowWidth * .8) },
	shuttle_map_img: { width: windowWidth, height: round(windowWidth * 1.474), marginBottom: 12 },
	shuttle_progress_img: { width: windowWidth, height: round(windowWidth * 1.426), marginBottom: 12 },
	shuttlestop_aa: { marginRight: 20, marginVertical: 50 },
	shuttle_stop_no_arrivals: { fontSize: 16, color: '#555' },

	// 403 - Dining List
	dining_listview: { padding: 8 },
	dl_market_name: { padding: 10 },
	dl_market_name_text: { color: '#333', fontSize: 26 },
	dl_market_desc_text: { color: '#555', paddingTop: 6, fontSize: 14 },
	dl_market_scroller: { height: 140 },
	dl_market_scroller_image: { width: 140, height: 140, borderRadius: 5, marginHorizontal: 7 },
	dl_market_directions: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', borderBottomWidth: 1, borderBottomColor: '#EEE', margin: 6, padding: 6 },
	dl_dir_label: { flex: 5, fontSize: 22, color: campus_primary },
	dl_dir_traveltype_container: { flex: 1, flexDirection: 'column', alignItems: 'center', justifyContent: 'center' },
	dl_dir_icon: { width: 28, height: 28 },
	dl_dir_eta: { color: campus_primary, fontSize: 11, fontWeight: '600' },
	dl_noresults: { color: '#444', fontSize: 15 },
	dl_market_date: { borderBottomWidth: 1, borderBottomColor: '#EEE', paddingBottom: 12, paddingTop: 6 },
	dl_market_date_label: { fontSize: 22, color: '#444', textAlign: 'center' },
	dl_market_filters_foodtype: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', marginVertical: 8 },
	dl_market_filters_mealtype: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', borderTopWidth: 1, borderTopColor: '#EEE', },
	dl_meal_button: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', height: 40, },
	dl_meal_button_active: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', height: 40, },
	dl_mealtype_circle: { borderWidth: 1, borderColor: '#CCC', borderRadius: 8, width: 16, height: 16, backgroundColor: '#CCC', marginRight: 5 },
	dl_mealtype_circle_active: { borderWidth: 1, borderColor: '#BBB', borderRadius: 8, width: 16, height: 16, backgroundColor: campus_primary, marginRight: 5 },
	dl_mealtype_label: { fontSize: 20, color: '#888', },
	dl_mealtype_label_active: { fontSize: 20, color: campus_primary, },
	dl_market_menu: { marginHorizontal: 8, marginVertical: 16 },
	dl_market_menu_row: { flexDirection: 'row', paddingBottom: 8 },
	dl_menu_item_name: { fontSize: 15, color: campus_primary },
	dl_menu_item_price: { color: '#555', paddingLeft: 26, marginLeft: 30 },

	// 404 - Dining Detail
	dd_menu_item_name: { fontSize: 22, color: campus_primary, paddingTop: 10, paddingLeft: 1 },
	ddn_container: { borderWidth: 2, borderColor: '#000', margin: 6, padding: 3 },
	ddn_header: { fontSize: 50, fontWeight: '700', backgroundColor: 'rgba(0,0,0,0)' },
	ddn_servingsize: { fontSize: 18 },
	ddn_amountperserving: { fontSize: 14, fontWeight: '700' },
	ddn_dv: { fontSize: 14, fontWeight: '700', textAlign: 'right', paddingVertical: 2 },
	ddn_bold: { fontSize: 18, fontWeight: '700' },
	ddn_font: { fontSize: 18 },
	ddn_row_main: { flex: 5, flexDirection: 'row', borderTopWidth: 1, borderTopColor: '#999', paddingVertical: 2 },
	ddn_row_sub: { flex: 5, flexDirection: 'row', borderTopWidth: 1, borderTopColor: '#999', paddingVertical: 2, paddingLeft: 20 },
	ddn_percent: { flex: 1, fontSize: 18, fontWeight: '700', textAlign: 'right' },
	ddn_topborder1: { borderTopWidth: 8, borderTopColor: '#000', paddingVertical: 2, marginTop: 2 },
	ddn_topborder2: { borderTopWidth: 4, borderTopColor: '#000' },
	ddn_topborder3: { borderTopWidth: 1, borderTopColor: '#999' },
	dd_menu_container: { justifyContent: 'center', alignItems: 'center', backgroundColor: campus_primary, borderRadius: 3, margin: 20, padding: 10 },
	dd_dining_menu: { marginHorizontal: 8 },
	dd_menu_text: { fontSize: 16, color: '#FFF' },

	// 405 - Welcome Week
	welcome_listview: {},
	welcome_ai: { alignItems: 'center', justifyContent: 'center', marginTop: windowHeight / 2 },
	welcome_list_row: { flexDirection: 'row', paddingVertical: 14, borderBottomWidth: 1, borderBottomColor: 'white', overflow: 'hidden', paddingLeft: 16, borderTopColor: 'white', justifyContent: 'center', alignItems: 'center'},
	welcome_list_sectionText: { fontSize: 18, color: '#FFF' },
	welcome_list_section: { flexDirection: 'column', justifyContent: 'center', alignItems: 'flex-start', padding: 6, backgroundColor: '#666' },
	welcome_list_left_container: { flexGrow: 1, marginRight: 14 },
	welcome_list_title: { fontSize: 17, color: '#000' },
	welcome_list_desc: { fontSize: 14, color: '#666', paddingTop: 3, paddingBottom: 6 },
	welcome_list_postdate: { fontSize: 11, color: campus_primary },
	welcome_list_image: { width: 130, height: 87, marginLeft: 14, borderWidth: 1, borderColor: '#CCC' },

	// 406 - Event & News Detail
	news_detail_container: { width: windowWidth, paddingHorizontal: 18, paddingVertical: 14 },
	eventdetail_top_container: { flexDirection: 'row', width: windowWidth, padding: 8 },
	eventdetail_eventname: { fontWeight: '400', fontSize: 22, color: campus_primary },
	eventdetail_eventlocation: { fontSize: 16, color: '#333' },
	eventdetail_eventdate: { fontSize: 11, color: '#333', paddingTop: 14 },
	eventdetail_eventdescription: { lineHeight: 18, color: '#111', fontSize: 14, paddingTop: 14 },
	eventdetail_eventcontact: { fontSize: 16, fontWeight: '600', color: '#333', paddingTop: 16 },
	eventdetail_readmore_container: { justifyContent: 'center', alignItems: 'center', backgroundColor: campus_primary, borderRadius: 3, marginTop: 20, padding: 10 },
	eventdetail_readmore_text: { fontSize: 16, color: '#FFF' },
	eventdetail_link: { fontSize: 16, fontWeight: '600', color: '#FFF', backgroundColor: campus_primary, borderWidth: 0, borderRadius: 3 },

	// 407 - WebView
	webview_container: { width: windowWidth, height: windowHeight - 60 },

	// 408 - Feedback
	feedback_container: { alignItems: 'flex-start', flexDirection: 'column', padding: 16, },
	feedback_label: { flex: 2, flexWrap: 'wrap', fontSize: 20, height: 80 },
	feedback_text: { flex: 1, fontSize: 20, alignItems: 'center', width: maxCardWidth - 32, height: 50 },
	feedback_submit: { flex:1, fontSize: 40, textAlign: 'center' },
	feedback_appInfo: { position: 'absolute', bottom: 0, right: 0, color: '#BBB', fontSize: 9, padding: 4 },

	// 409 - Preferences View
	preferencesContainer: { padding: 10, borderTopWidth: 1, borderTopColor: '#EEE' },
	prefCardTitle: { fontSize: 16, color: '#333' },

	// 410 - Links View
	links_row_full: { paddingHorizontal: 12 },


	/********************************************
	 *  500 - Modules
	 ********************************************/
	// 501 - Map Search
	map_searchbar_container: { width: maxCardWidth, height: 44, borderWidth: 0 },
	map_searchbar_input: { height: 44, padding: 8, paddingLeft: 40, backgroundColor: 'rgba(0,0,0,0)', zIndex: 10, color: '#555', fontSize: 20 },
	map_searchbar_icon: { position: 'absolute', top: 9, left: 8 },
	map_searchbar_ai: { position: 'absolute', top: 12, left: 8 },
	map_searchinfo: { padding: 16 },
	map_searchinfo_title: { fontSize: 18, fontWeight: '500', color: '#222', paddingBottom: 4 },
	map_searchinfo_desc: { fontSize: 16, color: '#444', lineHeight: 24 },

	// 502 - Search Results
	destinationcard_marker_label: { flex: 2, fontSize: 18, paddingLeft: 8, paddingTop: 0, color: campus_primary, justifyContent: 'center' },
	destinationcard_marker_dist_label: { flex: 1, textAlign: 'right', fontSize: 18, paddingLeft: 8, paddingTop: 0, color: campus_primary, justifyContent: 'center' },

	// 503 - LocationRequiredContent
	lrc_container: { flex: 1, alignItems: 'center', padding: 8, width: windowWidth },
	lrc_text_row: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', paddingTop: 10 },
	lrc_text: { fontSize: 14, color: '#777', paddingLeft: 6 },
	lrc_button: { justifyContent: 'center', alignItems: 'center', backgroundColor: campus_primary, borderRadius: 3, marginTop: 14, padding: 10 },
	lrc_button_text: { color: '#FFF' },


	/********************************************
	 *  900 - Misc
	 ********************************************/
	campus_primary: { color: campus_primary },
	whitebg: { backgroundColor: '#FFF' },
	offwhitebg: { backgroundColor: '#FAFAFA' },
	greybg: { backgroundColor: '#E2E2E2' },
	dgrey: { color: '#333' },
	grey: { color: '#666' },
	mgrey: { color: '#999' },
	lgrey: { color: '#CCC' },
	flex: { flex: 1 },
	center: { alignItems: 'center', justifyContent: 'center' },
	cardcenter: { alignItems: 'center', justifyContent: 'center', width: maxCardWidth },
	flexcenter: { flex: 1, alignItems: 'center', justifyContent: 'center', width: maxCardWidth },
	spacedRow: { flexDirection: 'row', justifyContent: 'space-between' },
	centerAlign: { alignSelf: 'center' },
	column: { flex: 1, flexDirection: 'column' },
	bold: { fontWeight: '700' },
	pad40: { padding: 40 },
	pt10: { paddingTop: 10 },
	fs12: { fontSize: 12 },
	fs18: { fontSize: 18 },

});

function round(number) {
	return Math.round(number);
}

module.exports = css;
