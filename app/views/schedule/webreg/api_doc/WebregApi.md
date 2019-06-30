### WebregCoursePlan - v1
####  QA and DEV Endpoints URL: https://api-qa.ucsd.edu:8243/webreg/courseplan/v1

| Method | Format | Description| Sample Response |
| -- | -- | -- | -- |
| GET| /students/{pid},{termCode},{academicLevel}/plannedCourses| Get planned courses| [getPlannedCourses.json](./getPlannedCourses.json) |
| GET|/students/{pid},{termCode},{academicLevel}/coursePlans| Get list of course plans| [getCoursePlansList.json](./getCoursePlansList.json)|
| GET | /students/{pid},{termCode},{academicLevel}/coursePlans/{coursePlan}/plannedCourses | Get planned courses for a named course plan| [getPlannedCourseForNamedCoursePlan.json](./getPlannedCourseForNamedCoursePlan.json)|
| DELETE|  /students/{pid},{termCode},{academicLevel}/coursePlans/{coursePlan}/plannedCourses/{sectionNumber} | Delete a course from a course plan| N/A |
| DELETE|  /students/{pid},{termCode},{academicLevel}/coursePlans/{coursePlan} | Delete a course plan| N/A |

### WebregWaitlist - v1
####  QA and DEV Endpoints URL: https://api-qa.ucsd.edu:8243/webreg/waitlist/v1
POST /classes/courseEligibility
DELETE /classes/{sectionID}/{pid}?
POST /classes/{sectionID}/{pid}?

| Method | Format | Sample Response |
| -- | -- | -- |
| POST| /classes/courseEligibility | N/A  |
| DELETE|/classes/{sectionID}/{pid}?| N/A |
| POST | /classes/{sectionID}/{pid}?| N/A |

### GetScheduleOfClasses - v1
####  QA and DEV Endpoints URL: https://api-qa.ucsd.edu:8243/get_schedule_of_classes/v1
| Method | Format | Description | Sample Response |
| -- | -- | -- | -- |
| GET|  /classes/{sectionId} | Retrieves a section by section ID. | [getClassBySectionId.json](./getClassBySectionId.json) |
| GET|  /classes/{termCode},{subjectCode},{courseCode} | Retrieves a section by term code, subject code, and course code. | [getClassByCode.json](./getClassByCode.json) |
| GET|  /classes/search | Queries for classes based on query parameter criteria. Only returns high level data that can be used to query for individual classes.| [classSearch.json](./classSearch.json) |
| GET|  /classes/{sectionId}/meetings| Retrieves all meeting entries for a section.| [classMeeting.json](./classMeeting.json) |
| GET|  /classes/{sectionId}/additional_meetings| Retrieves all meeting entries for a section.| [additonalMeeting.json](./additonalMeeting.json) |
| GET |  /classes/{sectionId}/instructors | Retrieves all instructors for a section. | [classInstructors.json](./classInstructors.json) |

### When an SSO access token is required:
1. Turn on debug mode on iOS simulator
2. Enter WebReg Home HomePage
3. Click the button "Get Access Token"
4. In React Native Debugger Console, copy the access token
5. Set request header `Authorization: Bear {YOUR_ACCESS_TOKEN}`
