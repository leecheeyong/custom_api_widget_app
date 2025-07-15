package com.example.custom_api_widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.app.PendingIntent
import android.graphics.Color
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.*

class ApiWidgetProvider : AppWidgetProvider() {
    
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val views = RemoteViews(context.packageName, R.layout.api_widget_layout)
        
        // Get widget data from shared preferences
        val widgetData = HomeWidgetPlugin.getData(context)
        val widgetTitle = widgetData.getString("widget_title", "API Widget")
        val widgetContent = widgetData.getString("widget_data", "No data available")
        val widgetColor = widgetData.getString("widget_color", "#6750A4")
        val lastUpdated = widgetData.getLong("last_updated", System.currentTimeMillis())
        
        // Update widget content
        views.setTextViewText(R.id.widget_title, widgetTitle)
        views.setTextViewText(R.id.widget_data, widgetContent)
        
        // Format timestamp
        val dateFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
        val timeString = dateFormat.format(Date(lastUpdated))
        views.setTextViewText(R.id.widget_timestamp, "Updated: $timeString")
        
        // Set color indicator
        try {
            val color = Color.parseColor(widgetColor)
            views.setInt(R.id.widget_color_indicator, "setBackgroundColor", color)
        } catch (e: Exception) {
            views.setInt(R.id.widget_color_indicator, "setBackgroundColor", Color.parseColor("#6750A4"))
        }
        
        // Set up refresh button click
        val refreshIntent = Intent(context, ApiWidgetProvider::class.java)
        refreshIntent.action = "REFRESH_WIDGET"
        refreshIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        val refreshPendingIntent = PendingIntent.getBroadcast(
            context, 
            appWidgetId, 
            refreshIntent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.refresh_button, refreshPendingIntent)
        
        // Set up widget click to open app
        val openAppIntent = Intent(context, MainActivity::class.java)
        val openAppPendingIntent = PendingIntent.getActivity(
            context, 
            0, 
            openAppIntent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_data, openAppPendingIntent)
        
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        if (intent.action == "REFRESH_WIDGET") {
            val appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
            if (appWidgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
                // Trigger Flutter app to refresh data
                val refreshIntent = Intent(context, MainActivity::class.java)
                refreshIntent.action = "REFRESH_WIDGET_DATA"
                refreshIntent.putExtra("widget_id", appWidgetId)
                refreshIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                context.startActivity(refreshIntent)
            }
        }
    }
}