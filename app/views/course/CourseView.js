/* eslint-disable class-methods-use-this */
import React, { Component } from 'react'
import { View } from 'react-native'
import CourseTableView from './CourseTableView'
import CourseDetailView from './CourseDetailView'
import CourseActionView from './CourseActionView'
import Course from './Course.json'

const CourseView = () => (
	<View style={{ flex: 1 }}>
		<CourseTableView style={{ marginTop: 16 }} />
		<CourseDetailView course={Course} sectCode="A01" style={{ marginTop: 16 }} />
		<CourseActionView course={Course} sectCode="A01" style={{ marginTop: 16 }} />
	</View>
)

export default CourseView
