import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  int colorValue; // Color를 int로 저장
  
  @HiveField(3)
  DateTime createdAt;
  
  @HiveField(4)
  List<String> completedDates; // ["2024-07-13", "2024-07-15"]
  
  Habit({
    String? id,
    required this.name,
    required this.colorValue,
    DateTime? createdAt,
    List<String>? completedDates,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       completedDates = completedDates ?? [];
  
  // Helper methods
  Color get color => Color(colorValue);
  void set color(Color value) => colorValue = value.value;
  
  bool isCompletedOn(DateTime date) {
    String dateStr = _dateToString(date);
    return completedDates.contains(dateStr);
  }
  
  void toggleDate(DateTime date) {
    String dateStr = _dateToString(date);
    // 새로운 리스트를 생성하여 할당 (웹 호환성)
    List<String> newDates = List<String>.from(completedDates);
    if (newDates.contains(dateStr)) {
      newDates.remove(dateStr);
    } else {
      newDates.add(dateStr);
    }
    completedDates = newDates;
    save();
  }
  
  int get totalCompletedDays => completedDates.length;
  
  int get currentStreak {
    if (completedDates.isEmpty) return 0;
    
    List<String> sorted = [...completedDates]..sort();
    DateTime today = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 365; i++) {
      DateTime checkDate = today.subtract(Duration(days: i));
      String dateStr = _dateToString(checkDate);
      
      if (sorted.contains(dateStr)) {
        streak++;
      } else if (i > 0) { // 오늘이 아닌 날부터 체크
        break;
      }
    }
    return streak;
  }
  
  int getCompletedDaysInMonth(DateTime month) {
    int count = 0;
    DateTime startOfMonth = DateTime(month.year, month.month, 1);
    DateTime endOfMonth = DateTime(month.year, month.month + 1, 0);
    
    for (int day = 1; day <= endOfMonth.day; day++) {
      DateTime checkDate = DateTime(month.year, month.month, day);
      if (isCompletedOn(checkDate)) {
        count++;
      }
    }
    return count;
  }
  
  String _dateToString(DateTime date) {
    return date.toIso8601String().substring(0, 10);
  }
  
  @override
  String toString() {
    return 'Habit{id: $id, name: $name, completedDates: ${completedDates.length}}';
  }
}