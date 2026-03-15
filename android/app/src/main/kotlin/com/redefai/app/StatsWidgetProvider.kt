package com.redefai.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

class StatsWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // home_widget saves data to 'HomeWidgetPreferences' SharedPreferences on Android
        val widgetData = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_stats)

            val quote = widgetData.getString("quote", "Strive not to be a success, but rather to be of value.")
            val focusValue = widgetData.getString("focus_value", "0")
            val focusUnit = widgetData.getString("focus_unit", "min")
            val streak = widgetData.getInt("habit_streak", 0)
            val pending = widgetData.getInt("pending_tasks", 0)

            views.setTextViewText(R.id.widget_quote, quote)
            views.setTextViewText(R.id.widget_focus_value, focusValue)
            views.setTextViewText(R.id.widget_focus_unit, focusUnit)
            views.setTextViewText(R.id.widget_streak_value, streak.toString())
            views.setTextViewText(R.id.widget_tasks_value, pending.toString())

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
