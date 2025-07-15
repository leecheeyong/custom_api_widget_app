import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_widget.dart';
import '../services/api_service.dart';

class WidgetProvider extends ChangeNotifier {
  List<ApiWidget> _widgets = [];
  bool _isLoading = false;

  List<ApiWidget> get widgets => _widgets;
  bool get isLoading => _isLoading;

  WidgetProvider() {
    loadWidgets();
  }

  Future<void> loadWidgets() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final widgetStrings = prefs.getStringList('widgets') ?? [];
      
      _widgets = widgetStrings
          .map((widgetString) => ApiWidget.fromJson(widgetString))
          .toList();
      
      // Refresh data for all widgets
      await refreshAllWidgets();
    } catch (e) {
      debugPrint('Error loading widgets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveWidgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final widgetStrings = _widgets.map((widget) => widget.toJson()).whereType<String>().toList();
      await prefs.setStringList('widgets', widgetStrings);
    } catch (e) {
      debugPrint('Error saving widgets: $e');
    }
  }

  Future<void> addWidget(ApiWidget widget) async {
    _widgets.add(widget);
    await saveWidgets();
    await refreshWidget(widget.id);
    notifyListeners();
  }

  Future<void> updateWidget(ApiWidget widget) async {
    final index = _widgets.indexWhere((w) => w.id == widget.id);
    if (index != -1) {
      _widgets[index] = widget;
      await saveWidgets();
      await refreshWidget(widget.id);
      notifyListeners();
    }
  }

  Future<void> deleteWidget(String id) async {
    _widgets.removeWhere((widget) => widget.id == id);
    await saveWidgets();
    notifyListeners();
  }

  Future<void> refreshWidget(String id) async {
    final index = _widgets.indexWhere((w) => w.id == id);
    if (index == -1) return;

    final widget = _widgets[index];
    _widgets[index] = widget.copyWith(isLoading: true);
    notifyListeners();

    try {
      final data = await ApiService.fetchData(widget.apiUrl, widget.dataPath);
      _widgets[index] = widget.copyWith(
        cachedData: data,
        lastUpdated: DateTime.now(),
        isLoading: false,
      );
      await saveWidgets();
    } catch (e) {
      debugPrint('Error refreshing widget $id: $e');
      _widgets[index] = widget.copyWith(isLoading: false);
    }
    
    notifyListeners();
  }

  Future<void> refreshAllWidgets() async {
    await Future.wait(_widgets.map((widget) => refreshWidget(widget.id)));
  }

  ApiWidget? getWidget(String id) {
    try {
      return _widgets.firstWhere((widget) => widget.id == id);
    } catch (e) {
      return null;
    }
  }
}