package edu.ucsd

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.Calendar

// Data is written by lib/core/services/home_widget.dart
private const val SIGNED_OUT = "Sign in to the UC San Diego app"

class StudentIdWidget : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        val views = RemoteViews(context.packageName, R.layout.student_id_widget).apply {
            setTextViewText(R.id.name, widgetData.getString("student_name", null) ?: SIGNED_OUT)
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
        val views = RemoteViews(context.packageName, R.layout.classes_widget).apply {
            setTextViewText(R.id.classes, if (classes == null) SIGNED_OUT else classes.ifEmpty { "No classes today" })
            setOnClickPendingIntent(R.id.root, HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java))
        }
        appWidgetManager.updateAppWidget(appWidgetIds, views)
    }
}
