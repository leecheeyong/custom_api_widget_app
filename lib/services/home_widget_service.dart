import 'package:home_widget/home_widget.dart';
import 'package:flutter/material.dart';
import '../models/api_widget.dart';

class HomeWidgetService {
  static const String _widgetName = 'ApiWidgetProvider';

  static Future<void> initializeHomeWidget() async {
    try {
      await HomeWidget.setAppGroupId('group.com.example.custom_api_widgets');
    } catch (e) {
      debugPrint('Error initializing home widget: $e');
    }
  }

  static Future<void> updateHomeWidget(ApiWidget widget) async {
    try {
      // Save widget data to shared preferences for the home widget
      await HomeWidget.saveWidgetData<String>('widget_title', widget.name);
      await HomeWidget.saveWidgetData<String>('widget_data', widget.cachedData ?? 'No data available');
      await HomeWidget.saveWidgetData<String>('widget_color', '#${widget.color.value.toRadixString(16).substring(2)}');
      await HomeWidget.saveWidgetData<int>('last_updated', widget.lastUpdated.millisecondsSinceEpoch);
      
      // Update the home widget
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _widgetName,
      );
    } catch (e) {
      debugPrint('Error updating home widget: $e');
    }
  }

  static Future<bool> requestPinWidget(ApiWidget widget) async {
    try {
      // Update widget data first
      await updateHomeWidget(widget);
      // Request to pin widget to home screen
      await HomeWidget.requestPinWidget(
        name: _widgetName,
        androidName: _widgetName,
      );
      return true;
    } catch (e) {
      debugPrint('Error requesting pin widget: $e');
      return false;
    }
  }

  static Future<void> removeAllWidgets() async {
    try {
      await HomeWidget.saveWidgetData<String>('widget_title', '');
      await HomeWidget.saveWidgetData<String>('widget_data', '');
      await HomeWidget.saveWidgetData<String>('widget_color', '');
      await HomeWidget.saveWidgetData<int>('last_updated', 0);
      
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _widgetName,
      );
    } catch (e) {
      debugPrint('Error removing widgets: $e');
    }
  }
}