import React from "react";
import { View, Text, ListView, StyleSheet } from "react-native";
import { getFinals } from "./scheduleData";
import Card from "../card/Card";
import logger from "../../util/logger";
import css from "../../styles/css";
import {
  COLOR_PRIMARY,
  COLOR_SECONDARY,
  COLOR_VDGREY,
  COLOR_DGREY,
  COLOR_MGREY,
  COLOR_LGREY,
  COLOR_WHITE,
  COLOR_BLACK,
  COLOR_DMGREY,
  COLOR_TRANSPARENT
} from "../../styles/ColorConstants";
import { MAX_CARD_WIDTH } from "../../styles/LayoutConstants";

const scheduleData = getFinals();
const dataSource = new ListView.DataSource({
  rowHasChanged: (r1, r2) => r1 !== r2
});

const FinalsCard = () => {
  logger.ga("Card Mounted: Finals Schedule");
  return (
    <Card id="finals" title="Finals Schedule">
      <ListView
        style={{ paddingTop: 0 }}
        enableEmptySections={true}
        dataSource={dataSource.cloneWithRows(scheduleData)}
        renderSeparator={(sectionID, rowID, adjacentRowHighlighted) =>
          scheduleData[rowID].length > 0 ? (
            <View
              style={{
                borderColor: "#EAEAEA",
                borderTopWidth: 1,
                width: MAX_CARD_WIDTH + 2
                // paddingBottom: 5,
              }}
              key={rowID}
            />
          ) : null
        }
        renderRow={(rowData, sectionID, rowID, highlightRow) => (
          <View>
            {scheduleData[String(rowID)].length > 0 ? (
              <ScheduleDay id={rowID} data={rowData} />
            ) : null}
          </View>
        )}
      />
    </Card>
  );
};

const dayOfWeekIntepreter = abbr => {
  fullString = "";
  switch (abbr) {
    case "MO":
      fullString = "Monday";
      break;
    case "TU":
      fullString = "Tuesday";
      break;
    case "WE":
      fullString = "Wednesday";
      break;
    case "TH":
      fullString = "Thursday";
      break;
    case "FR":
      fullString = "Friday";
      break;
    case "SA":
      fullString = "Saturday";
      break;
    case "SU":
      fullString = "Sunday";
      break;
    default:
      fullString = abbr;
  }
  return fullString;
};

var ScheduleDay = ({ id, data }) => (
  <View style={styles.card_content}>
    <Text style={styles.day_of_week}>{dayOfWeekIntepreter(id)}</Text>
    <DayList courseItems={data} />
  </View>
);

var DayList = ({ courseItems }) => (
  <ListView
    dataSource={dataSource.cloneWithRows(courseItems)}
    renderRow={(rowData, sectionID, rowID, highlightRow) => (
      <DayItem key={rowID} data={rowData} />
    )}
  />
);

var DayItem = ({ data }) => (
  <View style={styles.day_container}>
    <Text style={styles.course_title}>
      {data.subject_code} {data.course_code}
    </Text>
    <Text style={styles.course_text} numberOfLines={1}>
      {data.course_title}
    </Text>
    <Text style={styles.course_text}>
      {data.time_string + "\n"}
      {data.building + " " + data.room}
    </Text>
  </View>
);

const styles = StyleSheet.create({
  card_content: {
    width: MAX_CARD_WIDTH + 2,
    marginBottom: 10
  },
  day_of_week: {
    paddingTop: 10,
    paddingBottom: 5,
    paddingLeft: 15,
    fontWeight: "bold",
    fontSize: 18,
    color: COLOR_VDGREY
  },
  day_container: {
    paddingLeft: 15,
    // justifyContent: 'center',
    paddingBottom: 5,
    paddingTop: 5
  },
  course_title: {
    fontSize: 16,
    fontWeight: "bold",
    color: COLOR_VDGREY
  },
  course_text: {
    fontSize: 14,
    color: COLOR_DGREY
  }
});

export default FinalsCard;
