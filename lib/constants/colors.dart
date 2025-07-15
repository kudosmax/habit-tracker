import 'package:flutter/material.dart';

class AppColors {
  // 8가지 프리셋 색상 팔레트
  static const List<Color> habitColors = [
    Color(0xFFFFB347), // 오렌지 (기존 Scriptable과 동일)
    Color(0xFF4CAF50), // 그린
    Color(0xFF2196F3), // 블루
    Color(0xFF9C27B0), // 퍼플
    Color(0xFFFF5722), // 딥 오렌지
    Color(0xFF607D8B), // 블루 그레이
    Color(0xFFE91E63), // 핑크
    Color(0xFF795548), // 브라운
  ];
  
  // 활동 그리드 색상 (다크모드)
  static const Color gridBackground = Color(0xFF161B22);
  static const Color gridEmptyDay = Color(0xFF21262D);
  static const Color gridTodayBorder = Color(0xFF58A6FF);
  
  // 앱 테마 색상 (다크모드)
  static const Color primaryColor = Color(0xFF58A6FF);
  static const Color backgroundColor = Color(0xFF0D1117);
  static const Color cardColor = Color(0xFF161B22);
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color borderColor = Color(0xFF30363D);
  static const Color surfaceColor = Color(0xFF21262D);
  
  // 색상 이름 (선택 UI에서 사용)
  static const List<String> colorNames = [
    '오렌지',
    '그린',
    '블루',
    '퍼플',
    '딥 오렌지',
    '블루 그레이',
    '핑크',
    '브라운',
  ];
  
  static String getColorName(Color color) {
    int index = habitColors.indexWhere((c) => c.value == color.value);
    return index != -1 ? colorNames[index] : '커스텀';
  }
}