import 'package:home_widget/home_widget.dart';
import '../models/habit.dart';
import '../utils/date_utils.dart';

class WidgetService {
  static const String _appGroupId = 'group.com.habittracker.app';
  static const String _habitDataKey = 'habit_data';
  static const String _todayStatsKey = 'today_stats';

  // 위젯 초기화
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  // 습관 데이터를 위젯에 전달 (단순화된 버전)
  static Future<void> updateWidgetData(List<Habit> habits) async {
    try {
      if (habits.isEmpty) return;
      
      // 첫 번째 습관을 위젯에 표시 (나중에 사용자가 선택 가능하도록 확장)
      Habit primaryHabit = habits.first;
      
      // 간단한 위젯 데이터
      Map<String, dynamic> widgetData = {
        'habit_id': primaryHabit.id,
        'habit_name': primaryHabit.name,
        'habit_color': primaryHabit.color.value,
        'completed_today': primaryHabit.isCompletedOn(DateTime.now()),
        'current_streak': primaryHabit.currentStreak,
        'grid_data': _getRecentGridData(primaryHabit, 15), // 최근 15일 (작은 그리드)
      };

      // 위젯 데이터 저장
      await HomeWidget.saveWidgetData(_habitDataKey, widgetData);
      
      // 위젯 업데이트 요청 (단일 위젯만)
      await HomeWidget.updateWidget(
        name: 'SimpleHabitWidget',
        androidName: 'SimpleHabitWidget',
        iOSName: 'SimpleHabitWidget',
      );
      
    } catch (e) {
      print('Widget update failed: $e');
    }
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
    HomeWidget.widgetClicked.listen((Uri uri) {
      // 위젯 클릭 이벤트 처리
      String action = uri.queryParameters['action'] ?? 'open_app';
      Map<String, dynamic>? data = uri.queryParameters.isNotEmpty 
          ? Map<String, dynamic>.from(uri.queryParameters)
          : null;
      
      callback(action, data);
    });
  }

  // 위젯 권한 요청 (iOS 14+)
  static Future<bool> requestWidgetPermission() async {
    try {
      return await HomeWidget.requestWidgetPermission() ?? false;
    } catch (e) {
      print('Widget permission request failed: $e');
      return false;
    }
  }
}