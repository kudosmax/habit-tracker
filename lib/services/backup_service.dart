import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class BackupService {
  
  /// 전체 데이터를 JSON 형식으로 내보내기
  static Map<String, dynamic> exportToJson(List<Habit> habits) {
    return {
      'version': '1.0',
      'exported_at': DateTime.now().toIso8601String(),
      'app_name': 'Habit Tracker',
      'total_habits': habits.length,
      'habits': habits.map((habit) => {
        'id': habit.id,
        'name': habit.name,
        'color_value': habit.colorValue,
        'created_at': habit.createdAt.toIso8601String(),
        'completed_dates': habit.completedDates,
        'total_completed_days': habit.totalCompletedDays,
        'current_streak': habit.currentStreak,
      }).toList(),
    };
  }

  /// JSON 데이터를 파일로 다운로드 (웹 환경)
  static void downloadJsonFile(Map<String, dynamic> jsonData, String filename) {
    if (kIsWeb) {
      final jsonString = JsonEncoder.withIndent('  ').convert(jsonData);
      final bytes = utf8.encode(jsonString);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = filename;
      
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      
      html.Url.revokeObjectUrl(url);
    }
  }

  /// 백업 파일 다운로드 실행
  static void performBackup(List<Habit> habits) {
    final jsonData = exportToJson(habits);
    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    final filename = 'habit_tracker_backup_$timestamp.json';
    
    downloadJsonFile(jsonData, filename);
  }

  /// JSON 데이터에서 습관 목록 파싱
  static List<Habit> parseHabitsFromJson(Map<String, dynamic> jsonData) {
    final List<dynamic> habitsJson = jsonData['habits'] ?? [];
    
    return habitsJson.map((habitData) {
      // 필수 필드 검증
      if (habitData['id'] == null || 
          habitData['name'] == null || 
          habitData['created_at'] == null) {
        throw FormatException('Invalid habit data: missing required fields');
      }

      return Habit(
        id: habitData['id'],
        name: habitData['name'],
        colorValue: habitData['color_value'] ?? 0xFFFFB347, // 기본 오렌지 색상
        createdAt: DateTime.parse(habitData['created_at']),
        completedDates: List<String>.from(habitData['completed_dates'] ?? []),
      );
    }).toList();
  }

  /// 날짜 배열에서 습관 생성 (사용자 제공 데이터용)
  static Habit createHabitFromDates(String name, List<String> dates, {int? colorValue}) {
    // 날짜 유효성 검증 및 정렬
    final validDates = <String>[];
    DateTime? earliestDate;
    
    for (String dateStr in dates) {
      try {
        final date = DateTime.parse(dateStr);
        validDates.add(dateStr);
        
        if (earliestDate == null || date.isBefore(earliestDate)) {
          earliestDate = date;
        }
      } catch (e) {
        // 잘못된 날짜 형식은 무시
        print('Invalid date format: $dateStr');
      }
    }

    // 중복 제거 및 정렬
    final uniqueDates = validDates.toSet().toList();
    uniqueDates.sort();

    return Habit(
      name: name,
      colorValue: colorValue ?? 0xFFFFB347, // 기본 오렌지 색상
      createdAt: earliestDate ?? DateTime.now(),
      completedDates: uniqueDates,
    );
  }

  /// CSV 형식 파싱 (습관명,날짜1,날짜2,...)
  static List<Habit> parseHabitsFromCsv(String csvContent) {
    final lines = csvContent.split('\n');
    final habits = <Habit>[];
    
    for (String line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;
      
      final parts = trimmedLine.split(',');
      if (parts.isEmpty) continue;
      
      final habitName = parts[0].trim().replaceAll('"', '');
      if (habitName.isEmpty) continue;
      
      final dates = parts.skip(1)
          .map((date) => date.trim().replaceAll('"', ''))
          .where((date) => date.isNotEmpty)
          .toList();
      
      if (dates.isNotEmpty) {
        habits.add(createHabitFromDates(habitName, dates));
      }
    }
    
    return habits;
  }

  /// 데이터 무결성 검증
  static ValidationResult validateBackupData(Map<String, dynamic> jsonData) {
    final errors = <String>[];
    final warnings = <String>[];
    
    // 기본 구조 검증
    if (jsonData['habits'] == null) {
      errors.add('백업 파일에 습관 데이터가 없습니다');
      return ValidationResult(false, errors, warnings);
    }

    final List<dynamic> habitsJson = jsonData['habits'];
    
    // 각 습관 데이터 검증
    for (int i = 0; i < habitsJson.length; i++) {
      final habit = habitsJson[i];
      final habitIndex = i + 1;
      
      if (habit['id'] == null) {
        errors.add('습관 $habitIndex: ID가 없습니다');
      }
      
      if (habit['name'] == null || habit['name'].toString().trim().isEmpty) {
        errors.add('습관 $habitIndex: 이름이 없습니다');
      }
      
      if (habit['created_at'] == null) {
        errors.add('습관 $habitIndex: 생성 날짜가 없습니다');
      } else {
        try {
          DateTime.parse(habit['created_at']);
        } catch (e) {
          errors.add('습관 $habitIndex: 생성 날짜 형식이 잘못되었습니다');
        }
      }
      
      // 완료 날짜 배열 검증
      if (habit['completed_dates'] != null) {
        final dates = habit['completed_dates'];
        if (dates is List) {
          int invalidDateCount = 0;
          for (String dateStr in dates) {
            try {
              DateTime.parse(dateStr);
            } catch (e) {
              invalidDateCount++;
            }
          }
          
          if (invalidDateCount > 0) {
            warnings.add('습관 $habitIndex: $invalidDateCount개의 잘못된 날짜 형식이 있습니다');
          }
        }
      }
    }
    
    // 중복 ID 검증
    final ids = habitsJson
        .where((habit) => habit['id'] != null)
        .map((habit) => habit['id'].toString())
        .toList();
    
    final uniqueIds = ids.toSet();
    if (ids.length != uniqueIds.length) {
      warnings.add('중복된 습관 ID가 있습니다. 가져오기 시 새로운 ID가 생성됩니다.');
    }
    
    return ValidationResult(errors.isEmpty, errors, warnings);
  }

  /// 웹 환경에서 파일 선택 및 읽기
  static Future<String?> selectAndReadFile() async {
    if (!kIsWeb) return null;
    
    final completer = html.FileUploadInputElement();
    completer.accept = '.json,.csv';
    completer.click();
    
    await completer.onChange.first;
    
    if (completer.files?.isNotEmpty == true) {
      final file = completer.files!.first;
      final reader = html.FileReader();
      
      reader.readAsText(file);
      await reader.onLoad.first;
      
      return reader.result as String?;
    }
    
    return null;
  }

  /// 백업 파일 가져오기 및 처리
  static Future<ImportResult> importBackupFile() async {
    try {
      final fileContent = await selectAndReadFile();
      if (fileContent == null) {
        return ImportResult(false, '파일을 선택하지 않았습니다', []);
      }

      List<Habit> habits;
      
      // JSON 형식인지 CSV 형식인지 확인
      if (fileContent.trim().startsWith('{')) {
        // JSON 형식
        final jsonData = jsonDecode(fileContent);
        final validation = validateBackupData(jsonData);
        
        if (!validation.isValid) {
          return ImportResult(false, 
              '백업 파일이 손상되었습니다:\n${validation.errors.join('\n')}', []);
        }
        
        habits = parseHabitsFromJson(jsonData);
      } else {
        // CSV 형식
        habits = parseHabitsFromCsv(fileContent);
        
        if (habits.isEmpty) {
          return ImportResult(false, 'CSV 파일에서 유효한 습관 데이터를 찾을 수 없습니다', []);
        }
      }

      return ImportResult(true, '${habits.length}개의 습관을 성공적으로 가져왔습니다', habits);
      
    } catch (e) {
      return ImportResult(false, '파일 처리 중 오류가 발생했습니다: $e', []);
    }
  }

  /// 전체 데이터 삭제
  static Future<void> deleteAllData(HabitProvider provider) async {
    final habits = List<Habit>.from(provider.habits);
    
    for (Habit habit in habits) {
      await provider.deleteHabit(habit.id);
    }
  }
}

/// 검증 결과 클래스
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  
  ValidationResult(this.isValid, this.errors, this.warnings);
}

/// 가져오기 결과 클래스
class ImportResult {
  final bool success;
  final String message;
  final List<Habit> habits;
  
  ImportResult(this.success, this.message, this.habits);
}