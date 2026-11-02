package edu.ucsd

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.Calendar

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
            setImageViewBitmap(R.id.barcode, widgetData.getString("student_barcode", null)?.let(BitmapFactory::decodeFile))
            setOnClickPendingIntent(R.id.root, HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java))
        }
        appWidgetManager.updateAppWidget(appWidgetIds, views)
    }
}

class ClassesWidget : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        val day = arrayOf("SU", "MO", "TU", "WE", "TH", "FR", "SA")[Calendar.getInstance().get(Calendar.DAY_OF_WEEK) - 1]
        val classes = widgetData.getString("classes_$day", null)
        val signedOut = widgetData.getString("student_name", null) == null && widgetData.getString("student_barcode", null) == null
        val missing = if (signedOut) SIGNED_OUT else "Open the app to load your classes"
        val views = RemoteViews(context.packageName, R.layout.classes_widget).apply {
            setStudent(widgetData, null)
            setTextViewText(R.id.classes, classes?.ifEmpty { "No classes today" } ?: missing)
            setOnClickPendingIntent(R.id.root, HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java))
        }
        appWidgetManager.updateAppWidget(appWidgetIds, views)
    }
}
