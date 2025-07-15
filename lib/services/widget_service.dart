import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../utils/date_utils.dart';

// 웹 환경에서는 위젯 기능 제외
class WidgetService {
  static const String _appGroupId = 'group.com.habittracker.app';
  static const String _habitDataKey = 'habit_data';
  static const String _todayStatsKey = 'today_stats';

  // 위젯 초기화
  static Future<void> initialize() async {
    if (kIsWeb) return;
    // 웹에서는 위젯 기능 비활성화
    print('Widget service initialized (web platform - no widget support)');
  }

  // 습관 데이터를 위젯에 전달 (단순화된 버전)
  static Future<void> updateWidgetData(List<Habit> habits) async {
    if (kIsWeb) return;
    // 웹에서는 위젯 업데이트 비활성화
    print('Widget update skipped (web platform)');
  }

  // 최근 N일간의 그리드 데이터 생성
  static List<Map<String, dynamic>> _getRecentGridData(Habit habit, int days) {
    List<Map<String, dynamic>> gridData = [];
    DateTime now = DateTime.now();
    
    for (int i = days - 1; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      gridData.add({
        'date': DateHelper.dateToString(date),
        'completed': habit.isCompletedOn(date),
        'is_today': DateHelper.isToday(date),
      });
    }
    
    return gridData;
  }

  // 위젯에서 앱으로 전달되는 액션 처리 (단순화)
  static Future<void> handleWidgetAction(String action, Map<String, dynamic>? data) async {
    switch (action) {
      case 'toggle_today':
        // 오늘 날짜 토글 (가장 간단한 액션)
        if (data != null && data['habit_id'] != null) {
          print('Toggle today for habit: ${data['habit_id']}');
        }
        break;
      case 'open_app':
        // 앱 열기
        print('Open app from widget');
        break;
      default:
        print('Unknown widget action: $action');
    }
  }

  // 위젯 리스너 설정
  static void setupWidgetListener(Function(String, Map<String, dynamic>?) callback) {
    // Web에서는 위젯 기능이 지원되지 않으므로 빈 구현
    // 모바일에서만 실제 위젯 리스너 설정
  }

  // 위젯 권한 요청 (iOS 14+)
  static Future<bool> requestWidgetPermission() async {
    try {
      // Web에서는 위젯 기능이 지원되지 않으므로 false 반환
      return false;
    } catch (e) {
      print('Widget permission request failed: $e');
      return false;
    }
  }
}