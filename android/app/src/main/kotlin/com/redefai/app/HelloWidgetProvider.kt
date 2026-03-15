package com.redefai.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

class HelloWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_hello)

            // Data is currently hardcoded in the XML, but we can also set it here
            views.setTextViewText(R.id.widget_focus_value, "3")
            views.setTextViewText(R.id.widget_streak_value, "0")
            views.setTextViewText(R.id.widget_tasks_value, "1")

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}