package edu.ucsd

import org.json.JSONArray
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale
import java.util.TimeZone

internal val classDays = listOf("SU", "MO", "TU", "WE", "TH", "FR", "SA")
private val campusTimeZone = TimeZone.getTimeZone("America/Los_Angeles")

internal data class WidgetClass(val title: String, val location: String, val startMinutes: Int?)
internal data class UpcomingClass(val title: String, val location: String, val start: Long)

internal fun classSchedule(values: Map<String, String?>): Map<String, List<WidgetClass>>? {
    val schedule = mutableMapOf<String, List<WidgetClass>>()
    try {
        for ((day, value) in values) {
            if (value == null) continue
            val classes = JSONArray(value)
            schedule[day] = (0 until classes.length()).map { index ->
                val meeting = classes.getJSONObject(index)
                WidgetClass(meeting.getString("title"), meeting.getString("location"),
                    if (meeting.isNull("startMinutes")) null else meeting.getInt("startMinutes"))
            }
        }
    } catch (_: org.json.JSONException) {
        // Plain text from an older installation is replaced on the app's next sync.
        return null
    }
    return schedule.takeIf { it.isNotEmpty() }
}

internal fun upcomingClasses(schedule: Map<String, List<WidgetClass>>, now: Long): List<UpcomingClass> {
    val day = Calendar.getInstance(campusTimeZone).apply {
        timeInMillis = now
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
    }
    val upcoming = mutableListOf<UpcomingClass>()
    // Calendar days preserve campus start times across daylight-saving changes.
    repeat(15) {
        for (meeting in schedule[classDays[day.get(Calendar.DAY_OF_WEEK) - 1]].orEmpty()) {
            val minutes = meeting.startMinutes ?: continue
            if (minutes !in 0 until 1440) continue
            val start = (day.clone() as Calendar).apply {
                set(Calendar.HOUR_OF_DAY, minutes / 60)
                set(Calendar.MINUTE, minutes % 60)
            }.timeInMillis
            if (start > now) upcoming.add(UpcomingClass(meeting.title, meeting.location, start))
        }
        day.add(Calendar.DAY_OF_MONTH, 1)
    }
    return upcoming.sortedBy { it.start }.take(2)
}

internal fun classDetails(upcoming: UpcomingClass, now: Long): String {
    val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).apply { timeZone = campusTimeZone }
    val pattern = if (today.format(upcoming.start) == today.format(now)) "h:mm a" else "EEE h:mm a"
    val time = SimpleDateFormat(pattern, Locale.getDefault()).apply { timeZone = campusTimeZone }.format(upcoming.start)
    return "${upcoming.location.ifEmpty { "Location TBA" }} · $time"
}
