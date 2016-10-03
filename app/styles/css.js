/*
	Master Stylesheet for now@ucsandiego

	Device Pixel Ratios
		Ratio 1
			mdpi Android devices (160 dpi)
		Ratio 1.5
			hdpi Android devices (240 dpi)
		Ratio 2
			iPhone 4, 4S
			iPhone 5, 5c, 5s
			iPhone 6
			xhdpi Android devices (320 dpi)
		Ratio 3
			iPhone 6 plus
			xxhdpi Android devices (480 dpi)
		Ratio 3.5
			Nexus 6

	UCSD Branding Guidelines - Primary Colors
		New
		Blue:   #182B49
		Yellow: #C69214

		Old
		Blue: 	#006C92
		Grey: 	#747678
*/
'use strict';

import React from 'react';
import {
	StyleSheet,
	Dimensions,
	PixelRatio
} from 'react-native';

var AppSettings = require('../AppSettings');
var general = require('../util/general');
var logger = require('../util/logger');

var navBarMarginTop = 0;
var navBarTitleMarginTop = 5;

if (general.platformAndroid()) {
	navBarMarginTop = 64;
	navBarTitleMarginTop = 0;
} else if (general.platformIOS()) {
	
}

var pixelRatio = PixelRatio.get();
var windowSize = Dimensions.get('window');
var windowWidth = windowSize.width;
var windowHeight = windowSize.height;
var maxAppWidth = 414;

var welcome_ai_marginTop = (windowHeight / 2) - navBarMarginTop;

// Applying pixel ratio modifier helps ensure all views/layouts across devices render in similar fashion
var prm = windowWidth / maxAppWidth;

var maxCardWidth = windowWidth - 2 - 12;
var maxCardWidthWithPadding = windowWidth - 2 - 12 - 16; // border, margin, padding
var surfCardDetailsWidth = maxCardWidthWithPadding;
var surfCardDetailsPadding = 10 * prm;
var shuttleCardRefreshIconTop = 10;
var shuttleStopRefreshIconTop = 10;

if (pixelRatio === 2) {
	shuttleCardRefreshIconTop = 11;
	shuttleStopRefreshIconTop = 15;
} else if (pixelRatio === 3) {
	shuttleCardRefreshIconTop = 12;
	shuttleStopRefreshIconTop = 15;
}

var ucsdblue = '#006C92';
var ucsdgrey = '#747678';

var navMarginTop = 7;

var css = StyleSheet.create({

	// Navigator
	navBar: { flex: 1, backgroundColor: 'rgba(31,149,187,1)' },
		// Nav Bar Left
		navBarLeftButtonContainer: { flex: 1, alignItems: 'center', justifyContent: 'center', width: round(windowWidth * .166), marginBottom: 1 },
			navBarLeftButton: { color: '#FFF', fontSize: round(18 * prm), textAlign: 'center' },
		// Nav Bar Title
		navBarTitleContainer: { flex: 1, alignItems: 'center', justifyContent: 'center', width: round(windowWidth * .666), marginTop: navBarTitleMarginTop },
			navBarTitle: { color: '#FFF', fontSize: round(18 * prm), textAlign: 'center' },
		// Nav Bar Right
		navBarRightButtonContainer: { flex: 1, alignItems: 'center', justifyContent: 'center', width: round(windowWidth * .166) },

	// NavigatorIOS
	navBarIOS: {  },

	// Primary Containers
	main_container: { flex: 1, backgroundColor: '#EAEAEA', marginTop: navBarMarginTop },
	scroll_main: {  },
	listview_main: { marginTop: 64 },
	view_default: { paddingHorizontal: round(8 * prm) },
	scroll_default: { alignItems: 'center' },

	// Card Styles
	card_main: { borderWidth: 1, borderRadius: 2, borderColor: '#DDD', backgroundColor: '#F9F9F9', margin: 6, alignItems: 'flex-start', justifyContent: 'center', overflow: 'hidden' },
	card_plain: { margin: 6, alignItems: 'center', justifyContent: 'center' },
	card_special_events: { width: windowWidth - 12, height: round(windowWidth * .38 - 12) },
	card_view_overlay: { position: 'absolute', flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', bottom: 0, left: 0, width: windowWidth - 12, height: 48, backgroundColor: 'rgba(60,60,60,.8)'	},
	card_header_container: { borderBottomWidth: 1, borderBottomColor: '#EEE', width: maxCardWidthWithPadding },
	card_title_container: { flexDirection: 'row', alignItems: 'center', width: maxCardWidth, padding: 8, borderBottomWidth: 1, borderBottomColor: '#DDD' },
		card_title: { fontSize: round(26 * prm), color: ucsdgrey },

	// Modal Welcome Message
	modal_container: { flex: 1, backgroundColor: 'rgba(0, 108, 147, .95)', justifyContent: 'center', padding: round(35 * prm) },
	modal_text_intro: { color: '#FFF', fontSize: round(30 * prm), },
	modal_text: { color: '#FFF', marginTop: 30, fontSize: round(16 * prm), lineHeight: 20, marginBottom: 30 },
	modal_button: { borderWidth: 1, borderColor: '#FFF', padding: round(16 * prm), backgroundColor: 'rgba(50,50,50,.75)', justifyContent: 'center' },
	modal_button_text: { fontSize: round(24 * prm), color: '#FFF', textAlign: 'center' },

	// DINING CARD
	dining_card: { padding: 8 },
	dining_card_map: { width: maxCardWidthWithPadding },
	dining_card_filters: { flexDirection: 'row', justifyContent: 'center', marginBottom: 6 },
		dining_card_filter_button: { paddingVertical: 8, paddingHorizontal: 14, fontSize: round(14 * prm), color: ucsdblue, borderWidth: 1, borderColor: '#999', borderRadius: 3, backgroundColor: '#EEE', textAlign: 'center', marginHorizontal: 14 },
		dining_card_filter_button_active: { paddingVertical: 8, paddingHorizontal: 14, fontSize: round(14 * prm), color: '#EEE', borderWidth: 1, borderColor: '#999', borderRadius: 3, backgroundColor: ucsdblue, textAlign: 'center', marginHorizontal: 14, overflow: 'hidden' },
	dc_locations: { flex: 1, flexDirection: 'column' },
		dc_locations_row: { flexDirection: 'row', paddingBottom: 10, paddingTop: 10, borderBottomWidth: 1, borderBottomColor: '#EEE' },
			dc_locations_row_left: { flex: 6, justifyContent: 'center' },
				dc_locations_title: { fontSize: round(20 * prm), fontWeight: '500', color: ucsdblue },
				dc_locations_hours: { fontSize: round(12 * prm), color: '#666', paddingTop: 1 },
				dc_locations_description: { fontSize: round(12 * prm), color: '#666', paddingTop: 6 },
			dc_locations_row_right: { flex: 1, alignItems: 'center', justifyContent: 'center' },
				dc_locations_email_icon: { width: round(maxCardWidthWithPadding / 7 * .55), height: round(maxCardWidthWithPadding / 7 * .55 * .67) },
				dc_locations_email: { fontSize: round(12 * prm), textAlign: 'center', color: '#666' },
	dining_card_more: { alignItems: 'center', justifyContent: 'center', width: maxCardWidthWithPadding, paddingHorizontal: 4, paddingTop: 8, paddingBottom: 4, borderTopWidth: 1, borderTopColor: '#DDD' },
	dining_card_more_label: { fontSize: round(20 * prm), color: ucsdblue, fontWeight: '300' },

	// DINING LIST
	dl_market_name: { padding: round(10 * prm) },
		dl_market_name_text: { color: '#777', fontSize: round(26 * prm) },
	dl_market_scroller: { height: round(120 * prm) },
		dl_market_scroller_image: { width: round(120 * prm), height: round(120 * prm), borderRadius: round(5 * prm), marginHorizontal: round(7 * prm), borderWidth: 1, borderColor: '#CCC' },
	dl_market_directions: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', borderBottomWidth: 1, borderBottomColor: '#DDD', margin: round(6 * prm), padding: round(6 * prm) },
		dl_dir_label: { flex: 5, fontSize: round(22 * prm), color: ucsdblue },
		dl_dir_traveltype_container: { flex: 1, flexDirection: 'column', alignItems: 'center', justifyContent: 'center' },
			dl_dir_icon: { width: round(28 * prm), height: round(28 * prm) },
			dl_dir_eta: { color: ucsdblue, fontSize: round(11 * prm), fontWeight: '600' },
	dl_noresults: { color: '#444', fontSize: round(15 * prm) },
	dl_market_date: { borderBottomWidth: 1, borderBottomColor: '#DDD', paddingTop: round(16 * prm), paddingBottom: round(6 * prm) },
		dl_market_date_label: { fontSize: round(22 * prm), color: '#444', textAlign: 'center' },
	
	dl_market_filters_foodtype: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', marginVertical: round(8 * prm) },

	dl_market_filters_mealtype: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', borderTopWidth: 1, borderTopColor: '#DDD', paddingTop: round(10 * prm) },
		dl_meal_button: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center' },
			dl_mealtype_circle: { borderWidth: 1, borderColor: '#CCC', borderRadius: round(8 * prm), width: round(16 * prm), height: round(16 * prm), backgroundColor: '#CCC', marginRight: round(5 * prm) },
			dl_mealtype_circle_active: { borderWidth: 1, borderColor: '#BBB', borderRadius: 8, width: round(16 * prm), height: round(16 * prm), backgroundColor: ucsdblue, marginRight: round(5 * prm) },
			dl_mealtype_label: { fontSize: round(20 * prm), color: '#888' },
			dl_mealtype_label_active: { fontSize: round(20 * prm), color: ucsdblue },
	dl_market_menu: { marginHorizontal: round(8 * prm), marginVertical: round(16 * prm) },
		dl_market_menu_row: { flexDirection: 'row', paddingBottom: round(8 * prm) },
			dl_menu_item_name: { fontSize: round(15 * prm), color: ucsdblue },
			dl_menu_item_price: { color: '#555', paddingLeft: round(26 * prm), marginLeft: round(30 * prm) },

	// DINING DETAIL
	dd_menu_item_name: { fontSize: round(22 * prm), color: ucsdblue, paddingTop: 10, paddingLeft: 1 },

	ddn_container: { borderWidth: 2, borderColor: '#000', margin: 6, padding: 3 },
		ddn_header: { fontSize: round(50 * prm), fontWeight: '700', backgroundColor: 'rgba(0,0,0,0)' },
		ddn_servingsize: { fontSize: round(18 * prm) },
		ddn_amountperserving: { fontSize: round(14 * prm), fontWeight: '700' },
		ddn_dv: { fontSize: round(14 * prm), fontWeight: '700', textAlign: 'right', paddingVertical: 2 },
		ddn_bold: { fontSize: round(18 * prm), fontWeight: '700' },
		ddn_font: { fontSize: round(18 * prm) },
		ddn_row_main: { flex: 5, flexDirection: 'row', borderTopWidth: 1, borderTopColor: '#999', paddingVertical: 2 },
		ddn_row_sub: { flex: 5, flexDirection: 'row', borderTopWidth: 1, borderTopColor: '#999', paddingVertical: 2, paddingLeft: 20 },
		ddn_percent: { flex: 1, fontSize: round(18 * prm), fontWeight: '700', textAlign: 'right' },
		ddn_topborder1: { borderTopWidth: 8, borderTopColor: '#000', paddingVertical: 2, marginTop: 2 },
		ddn_topborder2: { borderTopWidth: 4, borderTopColor: '#000' },
		ddn_topborder3: { borderTopWidth: 1, borderTopColor: '#999' },
		dd_menu_container: { justifyContent: 'center', alignItems: 'center', backgroundColor: '#17AADF', borderRadius: 3, margin: round(20 * prm), padding: round(10 * prm) },
		dd_menu_text: { fontSize: round(16 * prm), color: '#FFF' },

	// SHUTTLE CARD
	shuttle_card_refresh_container: { position: 'absolute', alignItems: 'center', top: shuttleCardRefreshIconTop, right: round(4 * prm), width: round(50 * prm) },
		shuttle_card_refresh: { width: round(24 * prm), height: round(24 * prm) },
		shuttle_card_refresh_timeago: { fontSize: round(9 * prm), color: '#999', marginTop: round(-1 * prm), textAlign: 'center', fontWeight: '500', backgroundColor: 'rgba(0,0,0,0)' },

		shuttle_card_row: { width: maxCardWidth, overflow: 'hidden' },
		shuttle_card_err_row: { alignItems: 'center', justifyContent: 'center', width: maxCardWidth, overflow: 'hidden' },
		shuttle_card_row_center: { alignItems: 'center', justifyContent: 'center', width: maxCardWidth, overflow: 'hidden' },
		shuttle_card_loader: { height: round(350 * prm) },
		shuttle_card_row_border: { borderTopWidth: 1, borderTopColor: '#DDD' },
		shuttle_card_row_top: { flex: 1, flexDirection: 'row', alignItems: 'stretch', justifyContent: 'center', marginVertical: round(20 * prm), height: round(83 * prm) },
			shuttle_card_rt_1: { flex: 1 },
			shuttle_card_rt_2: { borderRadius: round(50 * prm), width: round(100 * prm), justifyContent: 'center' },
			shuttle_card_rt_2_label: { textAlign: 'center', color: '#222', fontWeight: '600', fontSize: round(48 * prm), backgroundColor: 'rgba(0,0,0,0)' },
			shuttle_card_rt_3: { flex: 3, justifyContent: 'center' },
			shuttle_card_rt_3_label: { textAlign: 'center', color: '#8f9092', fontSize: round(30 * prm), fontWeight: '300', backgroundColor: 'rgba(0,0,0,0)' },
			shuttle_card_rt_4: { borderRadius: round(49 * prm), borderWidth: 1, backgroundColor: '#FFF', borderColor: '#CCC', width: round(100 * prm), justifyContent: 'center' },
			shuttle_card_rt_4_label: { padding: 5, textAlign: 'center', color: '#8f9092', fontWeight: '500', fontSize: round(16 * prm), backgroundColor: 'rgba(0,0,0,0)' },
			shuttle_card_rt_5: { flex: 1 },
		shuttle_card_row_bot: { flex: 1, alignItems: 'center', paddingBottom: 20 },
		shuttle_card_row_arriving: { fontSize: round(26 * prm), color: '#333' },
		shuttlecard_loading: { marginHorizontal: 40, marginVertical: round(156 * prm) },
		shuttlecard_loading_fail: { marginHorizontal: round(16 * prm), marginTop: round(40 * prm), marginBottom: round(60 * prm) },

	// CARD GENERIC
	card_row_center: { alignItems: 'center', justifyContent: 'center', width: maxCardWidth, overflow: 'hidden' },
	card_loader: { height: round(278 * prm) },

	// EVENTS / TOP STORIES CARD
	events_list: { width: maxCardWidth, padding: 8 },
	events_list_row: { flex: 1, flexDirection: 'row', paddingVertical: 14, borderBottomWidth: 1, borderBottomColor: '#EEE', overflow: 'hidden' },
		events_list_left_container: { flex: 1 },
			events_list_title: { fontSize: round(17 * prm), color: '#000', fontWeight: '400' },
			events_list_desc: { fontSize: round(14 * prm), color: '#666', paddingTop: round(8 * prm) },
			events_list_postdate: { fontSize: round(11 * prm), color: ucsdblue, paddingTop: round(8 * prm) },
		events_list_image: { width: round(130 * prm), height: round(73 * prm), marginRight: 4, marginLeft: 10, borderWidth: 1, borderColor: '#CCC' },
		news_list_image: { width: round(130 * prm), height: round(87 * prm), marginRight: 4, marginLeft: 10, borderWidth: 1, borderColor: '#CCC' },
	events_more: { alignItems: 'center', justifyContent: 'center', width: maxCardWidthWithPadding, paddingHorizontal: 4, paddingTop: 8, paddingBottom: 4 },
	events_more_label: { fontSize: round(20 * prm), color: ucsdblue, fontWeight: '300' },
	events_card_container: { flex: 1, flexDirection: 'row', padding: 14, borderBottomWidth: 1, borderBottomColor: '#EEE', alignItems: 'center' },
		events_card_title_container: { flexDirection: 'row', alignItems: 'center', width: maxCardWidth, padding: 8, borderBottomWidth: 1, borderBottomColor: '#DDD' },
			events_card_title: { flex:1, flexWrap: 'wrap', fontSize: round(17 * prm), color: '#000', fontWeight: '400' },
		events_card_left_container: { flex: 10 },
			events_card_desc: { flexWrap: 'wrap', fontSize: round(14 * prm), color: '#666', paddingTop: round(8 * prm) },
			events_card_postdate: { fontSize: round(11 * prm), color: ucsdblue, paddingTop: round(8 * prm) },
		events_card_image: { flex: 1, width: round(130 * prm), height: round(73 * prm), marginRight: 4, marginLeft: 10, borderWidth: 1, borderColor: '#CCC'},

	// WELCOME WEEK STYLE
	welcome_listview: {  },
	welcome_ai: { alignItems: 'center', justifyContent: 'center', marginTop: welcome_ai_marginTop },
	welcome_list_row: { flex: 1, flexDirection: 'row', paddingVertical: 14, borderBottomWidth: 1, borderBottomColor: 'white', overflow: 'hidden', paddingLeft: 16, borderTopColor: 'white', justifyContent: 'center', alignItems: 'center'},
		welcome_list_sectionText: { fontSize: round(18 * prm), color: '#FFF' },
		welcome_list_section: { flexDirection: 'column', justifyContent: 'center', alignItems: 'flex-start', padding: 6, backgroundColor: '#666' },
		welcome_list_left_container: { flex: 1, marginRight: 14 },
			welcome_list_title: { fontSize: round(17 * prm), color: '#000' },
			welcome_list_desc: { fontSize: round(14 * prm), color: '#666', paddingTop: 3, paddingBottom: 6 },
			welcome_list_postdate: { fontSize: round(11 * prm), color: ucsdblue },
		welcome_list_image: { width: round(130 * prm), height: round(87 * prm), marginLeft: 14, borderWidth: 1, borderColor: '#CCC' },


	// WEATHER CARD
	weathercard_more: { justifyContent: 'center', width: windowWidth - 30, padding: round(10 * prm), fontSize: round(24 * prm), fontWeight: '500', color: ucsdblue },
	weathercard_border: { borderTopWidth: 1, borderTopColor: '#CCC', width: maxCardWidth },
	weatherccard_loading_height: { height: round(270 * prm) },

	wc_main: {  },
	wc_toprow: { flex: 1, flexDirection: 'row', borderBottomWidth: 1, borderColor: '#EEE', justifyContent: 'center', alignItems: 'center', width: maxCardWidth, paddingHorizontal: 14 },
		wc_toprow_left: { flex: 4 },
			wc_current_temp: { fontSize: round(22 * prm), fontWeight: '300' },
			wc_current_summary: { fontSize: round(15 * prm), color: '#444', paddingTop: 10, fontWeight: '300' },
		wc_toprow_right: { flex: 1 },
	wc_toprow_icon: { width: round(68 * prm), height: round(68 * prm) },

	wc_botrow: { flex: 1, flexDirection: 'row', padding: 20 },
		wc_botrow_col: { flex: 1, flexDirection: 'column', justifyContent: 'center', alignItems: 'center' },
			wf_dayofweek: { fontSize: round(14 * prm), fontWeight: '300', color: '#444', paddingBottom: 10},
			wf_icon: { height: round(33 * prm), width: round(33 * prm) },
			wf_tempMax: { fontSize: round(14 * prm), fontWeight: '300', color: '#000', paddingTop: 10 },
			wf_tempMin: { fontSize: round(14 * prm), fontWeight: '300', color: '#666', paddingTop: 10 },
	wc_surfreport_more: { fontSize: round(20 * prm), fontWeight: '300', color: ucsdblue, paddingHorizontal: 14, paddingVertical: 10 },

	// SURF REPORT
	sr_listview: {  },
	sr_image: { width: windowWidth, height: round(windowWidth * .361) },
	sr_day_row: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', padding: 10 },
		sr_day_row_border: { borderTopWidth: 1, borderTopColor: '#CCC' },
		sr_day_date_container: { flex: 1, alignItems: 'center', justifyContent: 'center' },
			sr_dayofweek: { fontSize: round(19 * prm), color: '#000' },
			sr_dayandmonth: { fontSize: round(12 * prm), color: '#777' },
		sr_day_details_container: { flex: 3, paddingLeft: 10, borderLeftWidth: 1, borderLeftColor: '#DDD' },
			sr_day_details_title: { fontSize: round(18 * prm), color: '#000' },
			sr_day_details_height: { fontSize: round(16 * prm), color: '#333', paddingTop: 4 },
			sr_day_details_desc: { fontSize: round(13 * prm), color: '#777', paddingTop: 4 },



	// DESTINATION CARD
	destinationcard_title: { flex: 1, alignSelf: 'stretch', fontSize: round(28 * prm), color: '#7d7e80', padding: 6 },
	destinationcard_bot_container: { padding: 8 },
	destinationcard_map_container: { flex:1, borderBottomWidth: 1, borderBottomColor: '#EAEAEA', paddingBottom: 16, margin: 8 },
		destinationcard_map: { borderWidth: 1, borderColor: '#DDD', width: maxCardWidthWithPadding, height: round(maxCardWidthWithPadding * .6) },
	destinationcard_marker_row: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', width: windowWidth - 30, padding: 6, marginTop: 0 },
	destinationcard_icon_marker: { width: 18, height: round(18 * 1.375), alignItems: 'flex-start', justifyContent: 'center' },
	destinationcard_marker_label: { flex: 1, fontSize: round(18 * prm), paddingLeft: 8, paddingTop: 0, color: ucsdblue, justifyContent: 'center' },


	// DestinationSearch
	dsearch_container: { flex: 1, backgroundColor: 'rgba(31,149,187,1)', width: windowWidth },
		dsearch_inner: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', paddingHorizontal: round(20 * prm), margin: round(8 * prm), backgroundColor: '#FFF', borderWidth: 1, borderRadius: 2, borderColor: 'rgba(0,0,0,0)' },
			dsearch_searchicon: { width: round(24 * prm), height: round(24 * prm) },
			dsearch_textinput: { flex: 1, height: round(50 * prm), marginHorizontal: 8, fontSize: round(24 * prm), color: '#999', textAlign: 'center', fontWeight: '500' },
			dsearch_micicon: { width: round(24 * .736 * prm), height: round(24 * prm) },


	// Card Overlay
	events_img: { width: maxCardWidthWithPadding, height: round(maxCardWidthWithPadding * .23) },
	topstories_img: { width: maxCardWidthWithPadding, height: round(maxCardWidthWithPadding * .1) },
	card_text_1: { fontSize: round(20 * prm), color: "#666", padding: 20, fontWeight: "bold" },


	// EVENT DETAIL
	eventdetail_top_container: { flex: 1, flexDirection: 'row', width: windowWidth, padding: 8 },
		
		eventdetail_image: { width: windowWidth, height: round(windowWidth * .5) },
		eventdetail_image2: { width: 50, height: 50 },
		eventdetail_image2_sm: { width: 100, height: 100, borderColor: 'blue', borderWidth: 1 },
		eventdetail_image2_lg: { width: 200, height: 200 },
		news_detail_container: { width: windowWidth, paddingHorizontal: round(18 * prm), paddingVertical: round(14 * prm) },
			eventdetail_eventname: { fontWeight: '400', fontSize: round(22 * prm), color: ucsdblue },
			eventdetail_eventlocation: { fontSize: round(16 * prm), color: '#333' },
			eventdetail_eventdate: { fontSize: round(11 * prm), color: '#333', paddingTop: round(14 * prm) },
			eventdetail_eventdescription: { lineHeight: round(18 * prm), color: '#111', fontSize: round(14 * prm), paddingTop: round(14 * prm) },
			eventdetail_eventcontact: { fontSize: round(16 * prm), fontWeight: '600', color: '#333', paddingTop: 16 },

		eventdetail_readmore_container: { justifyContent: 'center', alignItems: 'center', backgroundColor: '#17AADF', borderRadius: 3, marginTop: 20, padding: 10 },
			eventdetail_readmore_text: { fontSize: round(16 * prm), color: '#FFF' },
			eventdetail_link: { fontSize: round(16 * prm), fontWeight: '600', color: '#FFF', backgroundColor: '#17AADF', borderWidth: 0, borderRadius: 3 },



	// SPECIAL EVENTS CARD
	special_events_main: { flex: 1 },
	special_events_webview: { },


	// Events styles
	events_main: { flex: 1, flexDirection: 'column', justifyContent: 'center', alignItems: 'center' },
	events_listing_img: { width: windowWidth - 12, height: round(windowWidth * 1.267 - 12), margin: 6 },

	// Refresh loader
	load_icon: { width: round(48 * prm), height: round(48 * prm) },



	// SHUTTLE STOP
	shuttlestop_image: { width: windowWidth, height: round(windowWidth * .533) },
	shuttlestop_name_container: { flex: 1, flexDirection: 'row', alignItems: 'center', width: windowWidth, paddingVertical: round(14 * prm), paddingHorizontal: round(20 * prm), backgroundColor: ucsdblue },
		shuttlestop_name_text: { width: round(windowWidth * .9 - 40), color: '#FFF', fontSize: round(24 * prm), fontWeight: '300' },
		
		shuttlestop_refresh_container: { position: 'absolute', alignItems: 'center', top: shuttleStopRefreshIconTop, right: 8, width: round(55 * prm) },
			shuttlestop_refresh: { width: round(26 * prm), height: round(26 * prm) },
			shuttlestop_refresh_timeago: { fontSize: round(10 * prm), color: '#FFF', marginTop: round(1 * prm), textAlign: 'center', fontWeight: '600', backgroundColor: 'rgba(0,0,0,0)' },

	shuttle_stop_arrivals_container: { width: windowWidth, paddingLeft: round(20 * prm), paddingVertical: round(16 * prm) },
		shuttle_stop_next_arrivals_text: { fontSize: round(20 * prm), fontWeight: '300', color: '#222', paddingTop: 8, paddingBottom: 16 },
		shuttle_stop_arrivals_row: { flex: 1, flexDirection: 'row', paddingBottom: 13, alignItems: 'center', justifyContent: 'flex-start' },
			shuttle_stop_rt_2: { borderRadius: round(18 * prm), width: round(36 * prm), height: round(36 * prm), justifyContent: 'center' },
				shuttle_stop_rt_2_label: { textAlign: 'center', fontWeight: '600', fontSize: round(19 * prm), backgroundColor: 'rgba(0,0,0,0)' },
			shuttle_stop_arrivals_row_route_name: { flex: 2, fontSize: round(17 * prm), color: '#555', paddingLeft: round(10 * prm) },
			shuttle_stop_arrivals_row_eta_text: { flex: 1, fontSize: round(20 * prm), color: '#333', paddingLeft: round(16 * prm), paddingRight: round(16 * prm)  },
		
		shuttlestop_loading: { width: 48, height: 48, marginHorizontal: 40, marginVertical: round(50 * prm) },

		shuttle_stop_map_text: { fontSize: round(20 * prm), fontWeight: '300', paddingTop: 16, color: '#222', paddingLeft: round(20 * prm), paddingBottom: 8 },
		shuttlestop_map: { width: windowWidth, height: round(windowWidth * .8) },
		shuttle_map_img: { width: windowWidth, height: round(windowWidth * 1.474), marginBottom: 12 },
		shuttle_progress_img: { width: windowWidth, height: round(windowWidth * 1.426), marginBottom: 12 },

		shuttlestop_aa: { marginRight: 20, marginVertical: 50 },

	shuttle_stop_no_arrivals: { fontSize: round(16 * prm), color: '#555' },

	// Weather Styles
	weather_main: { flex: 1, paddingBottom: 12 },
	weather_webview: { backgroundColor: '#EAEAEA', paddingBottom:40 },


	// Destination Styles
	destination_search_img: { width: windowWidth, height: round(windowWidth * .158) },
	destination_suggestions_img: { width: windowWidth, height: round(windowWidth * .559) },
	destination_results_img: { width: windowWidth, height: round(windowWidth * 1.864) },

	// Destination Detail
	destination_detail_sc: { },
	destination_detail_map: { width: windowWidth, height: windowHeight - 60 },

	// WebView
	webview_container: { width: windowWidth, height: windowHeight - 60 },

	// Footer
	footer: { flex: 1, flexDirection: 'row', paddingBottom: 10 },
	footer_link: { flex: 15 },
	
	footer_about: { color: ucsdblue, fontSize: round(16 * prm), textAlign: 'center', padding: 4 },
	footer_spacer: { flex: 1, color: '#888', padding: 4, fontSize: round(16 * prm), textAlign: 'center' },
	footer_copyright: { color: ucsdblue, fontSize: round(16 * prm), textAlign: 'center', padding: 4 },

	// Feedback
	feedback_container: { flex:1, width: maxCardWidthWithPadding, padding: 16, },
	feedback_label: { flex:1, fontSize: round(20 * prm), height: 40},
	feedback_text: { flex:1, alignItems: 'center', width: maxCardWidth - 32, height: round(50*prm) },
	feedback_submit: { fontSize: round(40 * prm), textAlign: 'center' },

	// MISC STYLES
	whitebg: { backgroundColor: '#FFF' },
	offwhitebg: { backgroundColor: '#FAFAFA' },
	greybg: { backgroundColor: "#E2E2E2" },
	dgrey: { color: '#333' },
	grey: { color: '#666' },
	mgrey: { color: '#999' },
	lgrey: { color: '#CCC' },
	flex: { flex: 1 },
	center: { alignItems: 'center', justifyContent: 'center' },
	cardcenter: { alignItems: 'center', justifyContent: 'center', width: maxCardWidth },
	flexcenter: { flex: 1, alignItems: 'center', justifyContent: 'center', width: maxCardWidth },
	flexcenter2: { flex: 1, alignItems: 'center', justifyContent: 'center', width: maxCardWidthWithPadding },
	flexcenter3: { flex: 1, alignItems: 'center', justifyContent: 'center', width: windowWidth },

	card_loading_img: { width: 64, height: 64 },

	bold: { fontWeight: '700' },

	pad10: { padding: 10 },
	pad20: { padding: 20 },
	pad30: { padding: 30 },
	pad40: { padding: 40 },
	mar10: { margin: 10 },
	mar20: { margin: 20 },
	mar30: { margin: 30 },
	mar40: { margin: 40 },
	pt10:  { paddingTop: 10 },

	fs10: { fontSize: round(10 * prm) },
	fs12: { fontSize: round(12 * prm) },
	fs14: { fontSize: round(14 * prm) },
	fs16: { fontSize: round(16 * prm) },
	fs18: { fontSize: round(18 * prm) },
	fs20: { fontSize: round(20 * prm) },
	fs22: { fontSize: round(22 * prm) },
	fs24: { fontSize: round(24 * prm) },

});

function round(number) {
	return Math.round(number);
}

module.exports = css;