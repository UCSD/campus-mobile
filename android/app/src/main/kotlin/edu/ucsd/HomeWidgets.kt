package edu.ucsd

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.os.Bundle
import android.os.SystemClock
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetScheduler

// Data is written by lib/core/services/home_widget.dart
private const val SIGNED_OUT = "Sign in to the UC San Diego app"

/** Name and major (layout/widget_student.xml); [signedOutText] replaces the name when signed out. */
private fun RemoteViews.setStudent(widgetData: SharedPreferences, signedOutText: String?) {
    showText(R.id.name, widgetData.getString("student_name", null) ?: signedOutText)
    showText(R.id.major, widgetData.getString("student_major", null))
}

private fun RemoteViews.showText(id: Int, text: String?) {
    setTextViewText(id, text.orEmpty())
    setViewVisibility(id, if (text.isNullOrEmpty()) View.GONE else View.VISIBLE)
}

class StudentIdWidget : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        val views = RemoteViews(context.packageName, R.layout.student_id_widget).apply {
            setStudent(widgetData, if (widgetData.getString("student_barcode", null) == null) SIGNED_OUT else null)
            setViewVisibility(R.id.major, View.GONE)
            setImageViewBitmap(R.id.barcode, widgetData.getString("student_barcode", null)?.let(BitmapFactory::decodeFile))
            setOnClickPendingIntent(R.id.root, HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java))
        }
        appWidgetManager.updateAppWidget(appWidgetIds, views)
    }
}

class ClassesWidget : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        val now = System.currentTimeMillis()
        val schedule = classSchedule(classDays.associateWith { widgetData.getString("classes_$it", null) })
        val classes = upcomingClasses(schedule.orEmpty(), now)
        val signedOut = widgetData.getString("student_name", null) == null && widgetData.getString("student_barcode", null) == null
        val missing = if (signedOut) SIGNED_OUT else "Open the app to load your classes"
        val views = RemoteViews(context.packageName, R.layout.classes_widget).apply {
            val next = classes.firstOrNull()
            setViewVisibility(R.id.next_class, if (next == null) View.GONE else View.VISIBLE)
            setViewVisibility(R.id.following_class, if (classes.size > 1) View.VISIBLE else View.GONE)
            showText(R.id.classes, if (next != null) null else when {
                schedule == null -> missing
                schedule.values.any { it.isNotEmpty() } -> "Class times unavailable"
                else -> "No upcoming classes"
            })
            if (next != null) {
                setTextViewText(R.id.next_class_title, next.title)
                setTextViewText(R.id.next_class_details, classDetails(next, now))
                setChronometerCountDown(R.id.class_countdown, true)
                setChronometer(R.id.class_countdown, SystemClock.elapsedRealtime() + next.start - now, "Starts in %s", true)
            } else {
                setChronometer(R.id.class_countdown, 0, null, false)
            }
            if (classes.size > 1) {
                setTextViewText(R.id.following_class_title, classes[1].title)
                setTextViewText(R.id.following_class_details, classDetails(classes[1], now))
            }
            setOnClickPendingIntent(R.id.root, HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java))
        }
        for (id in appWidgetIds) {
            val options = appWidgetManager.getAppWidgetOptions(id)
            val isSmall = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH) < 250 ||
                options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT) < 180
            val sizedViews = RemoteViews(views).apply {
                val padding = ((if (isSmall) 8 else 12) * context.resources.displayMetrics.density).toInt()
                setViewPadding(R.id.root, padding, padding, padding, padding)
                setViewVisibility(R.id.next_class_label, if (isSmall) View.GONE else View.VISIBLE)
                setTextViewTextSize(R.id.next_class_title, TypedValue.COMPLEX_UNIT_SP, if (isSmall) 16f else 20f)
                setTextViewTextSize(R.id.next_class_details, TypedValue.COMPLEX_UNIT_SP, if (isSmall) 10f else 12f)
                setTextViewTextSize(R.id.class_countdown, TypedValue.COMPLEX_UNIT_SP, if (isSmall) 10f else 12f)
                setTextViewTextSize(R.id.following_class_details, TypedValue.COMPLEX_UNIT_SP, if (isSmall) 10f else 11f)
                setInt(R.id.following_class_details, "setMaxLines", if (isSmall) 2 else 1)
                if (isSmall && classes.isNotEmpty()) {
                    setTextViewText(R.id.next_class_details, classes.first().location.ifEmpty { "Location TBA" })
                }
            }
            appWidgetManager.updateAppWidget(id, sizedViews)
        }
        // Reuse the plugin's scheduler to promote the next class, including after reboot.
        HomeWidgetScheduler.schedule(context, javaClass.name, classes.take(1).map { it.start })
    }

    override fun onAppWidgetOptionsChanged(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int, newOptions: Bundle) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId))
    }

    override fun onDisabled(context: Context) {
        HomeWidgetScheduler.cancel(context, javaClass.name)
        super.onDisabled(context)
    }
}
