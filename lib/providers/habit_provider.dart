import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../constants/constants.dart';
import '../services/widget_service.dart';

class HabitProvider extends ChangeNotifier {
  late Box<Habit> _habitBox;
  List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  // Hive 초기화
  Future<void> initHive() async {
    await Hive.initFlutter();
    
    // 어댑터가 이미 등록되어 있는지 확인
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitAdapter());
    }
    
    _habitBox = await Hive.openBox<Habit>(AppConstants.habitBoxName);
    _loadHabits();
    
    // 위젯 서비스 초기화
    await WidgetService.initialize();
    _updateWidget();
    
    // 위젯 액션 리스너 설정
    WidgetService.setupWidgetListener(_handleWidgetAction);
  }

  void _loadHabits() {
    _habits = _habitBox.values.toList();
    notifyListeners();
  }

  // 습관 추가
  Future<void> addHabit(Habit habit) async {
    await _habitBox.put(habit.id, habit);
    _habits.add(habit);
    notifyListeners();
    _updateWidget();
  }

  // 습관 삭제
  Future<void> deleteHabit(String habitId) async {
    await _habitBox.delete(habitId);
    _habits.removeWhere((habit) => habit.id == habitId);
    notifyListeners();
    _updateWidget();
  }

  // 습관 업데이트
  Future<void> updateHabit(Habit habit) async {
    await _habitBox.put(habit.id, habit);
    int index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      notifyListeners();
      _updateWidget();
    }
  }

  // 습관 찾기
  Habit? getHabit(String habitId) {
    try {
      return _habits.firstWhere((habit) => habit.id == habitId);
    } catch (e) {
      return null;
    }
  }

  // 날짜 토글 (체크/해제)
  Future<void> toggleHabitDate(String habitId, DateTime date) async {
    Habit? habit = getHabit(habitId);
    if (habit != null) {
      habit.toggleDate(date);
      await _habitBox.put(habitId, habit);
      notifyListeners();
      _updateWidget();
    }
  }

  // 오늘 완료된 습관 개수
  int get todayCompletedCount {
    DateTime today = DateTime.now();
    return _habits.where((habit) => habit.isCompletedOn(today)).length;
  }

  // 전체 습관 개수
  int get totalHabitsCount => _habits.length;

  // 오늘 완료율 (퍼센트)
  double get todayCompletionRate {
    if (_habits.isEmpty) return 0.0;
    return (todayCompletedCount / totalHabitsCount) * 100;
  }

  // 이번 달 통계
  Map<String, int> getMonthlyStats(DateTime month) {
    int totalDaysInMonth = DateTime(month.year, month.month + 1, 0).day;
    int completedDays = 0;
    
    for (Habit habit in _habits) {
      completedDays += habit.getCompletedDaysInMonth(month);
    }
    
    return {
      'totalPossible': _habits.length * totalDaysInMonth,
      'completed': completedDays,
      'completionRate': _habits.isEmpty ? 0 : ((completedDays / (_habits.length * totalDaysInMonth)) * 100).round(),
    };
  }

  // 위젯 데이터 업데이트
  void _updateWidget() {
    WidgetService.updateWidgetData(_habits);
  }

  // 위젯에서 오는 액션 처리 (단순화)
  void _handleWidgetAction(String action, Map<String, dynamic>? data) {
    switch (action) {
      case 'toggle_today':
        // 오늘 날짜만 토글 (가장 간단)
        if (data != null && data['habit_id'] != null) {
          toggleHabitDate(data['habit_id'], DateTime.now());
        }
        break;
      default:
        // 다른 모든 액션은 앱 열기
        print('Open app from widget action: $action');
    }
  }

  // 위젯 권한 요청
  Future<bool> requestWidgetPermission() async {
    return await WidgetService.requestWidgetPermission();
  }

  @override
  void dispose() {
    _habitBox.close();
    super.dispose();
  }
}