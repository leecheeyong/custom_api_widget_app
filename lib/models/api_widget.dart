import 'dart:convert';
import 'package:flutter/material.dart';

class ApiWidget {
  final String id;
  final String name;
  final String apiUrl;
  final String dataPath;
  final Color color;
  final int refreshInterval;
  final DateTime createdAt;
  final DateTime lastUpdated;
  String? cachedData;
  bool isLoading;

  ApiWidget({
    required this.id,
    required this.name,
    required this.apiUrl,
    required this.dataPath,
    required this.color,
    required this.refreshInterval,
    required this.createdAt,
    required this.lastUpdated,
    this.cachedData,
    this.isLoading = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'apiUrl': apiUrl,
      'dataPath': dataPath,
      'color': color.value,
      'refreshInterval': refreshInterval,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'cachedData': cachedData,
    };
  }

  factory ApiWidget.fromMap(Map<String, dynamic> map) {
    return ApiWidget(
      id: map['id'],
      name: map['name'],
      apiUrl: map['apiUrl'],
      dataPath: map['dataPath'],
      color: Color(map['color']),
      refreshInterval: map['refreshInterval'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated']),
      cachedData: map['cachedData'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ApiWidget.fromJson(String source) => ApiWidget.fromMap(json.decode(source));

  ApiWidget copyWith({
    String? id,
    String? name,
    String? apiUrl,
    String? dataPath,
    Color? color,
    int? refreshInterval,
    DateTime? createdAt,
    DateTime? lastUpdated,
    String? cachedData,
    bool? isLoading,
  }) {
    return ApiWidget(
      id: id ?? this.id,
      name: name ?? this.name,
      apiUrl: apiUrl ?? this.apiUrl,
      dataPath: dataPath ?? this.dataPath,
      color: color ?? this.color,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      cachedData: cachedData ?? this.cachedData,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}