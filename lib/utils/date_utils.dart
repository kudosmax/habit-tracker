import 'package:intl/intl.dart';

class DateHelper {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayFormat = DateFormat('M월 d일');
  static final DateFormat _monthFormat = DateFormat('yyyy년 M월');

  // DateTime을 문자열로 변환
  static String dateToString(DateTime date) {
    return _dateFormat.format(date);
  }

  // 문자열을 DateTime으로 변환
  static DateTime? stringToDate(String dateString) {
    try {
      return _dateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // 표시용 날짜 문자열
  static String formatDisplayDate(DateTime date) {
    return _displayFormat.format(date);
  }

  // 월 표시용 문자열
  static String formatMonth(DateTime date) {
    return _monthFormat.format(date);
  }

  // 오늘 날짜인지 확인
  static bool isToday(DateTime date) {
    DateTime today = DateTime.now();
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }

  // 같은 날짜인지 확인
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // 연간 그리드를 위한 날짜 리스트 생성 (365일)
  static List<DateTime> generateYearGrid({DateTime? endDate}) {
    DateTime end = endDate ?? DateTime.now();
    List<DateTime> dates = [];
    
    for (int i = 364; i >= 0; i--) {
      dates.add(end.subtract(Duration(days: i)));
    }
    
    return dates;
  }

  // 주의 시작 날짜 (일요일) 찾기
  static DateTime getStartOfWeek(DateTime date) {
    int daysFromSunday = date.weekday % 7;
    return date.subtract(Duration(days: daysFromSunday));
  }

  // 월의 시작 날짜
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // 월의 마지막 날짜
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // 연속 기록 계산
  static int calculateStreak(List<String> completedDates, {DateTime? endDate}) {
    if (completedDates.isEmpty) return 0;
    
    DateTime end = endDate ?? DateTime.now();
    List<String> sortedDates = [...completedDates]..sort();
    int streak = 0;
    
    // 오늘부터 거꾸로 확인
    for (int i = 0; i < 365; i++) {
      DateTime checkDate = end.subtract(Duration(days: i));
      String dateStr = dateToString(checkDate);
      
      if (sortedDates.contains(dateStr)) {
        streak++;
      } else if (i > 0) { // 오늘이 아닌 날부터 체크
        break;
      }
    }
    
    return streak;
  }

  // 두 날짜 사이의 일수 계산
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  // 월별 완료일 수 계산
  static int getCompletedDaysInMonth(List<String> completedDates, DateTime month) {
    int count = 0;
    DateTime startOfMonth = getStartOfMonth(month);
    DateTime endOfMonth = getEndOfMonth(month);
    
    for (String dateStr in completedDates) {
      DateTime? date = stringToDate(dateStr);
      if (date != null && 
          date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          date.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        count++;
      }
    }
    
    return count;
  }

  // 상대적 날짜 문자열 (예: "오늘", "어제", "3일 전")
  static String getRelativeDateString(DateTime date) {
    DateTime now = DateTime.now();
    int difference = daysBetween(date, now);
    
    if (difference == 0) return '오늘';
    if (difference == 1) return '어제';
    if (difference == -1) return '내일';
    if (difference > 0) return '$difference일 전';
    return '${-difference}일 후';
  }
}