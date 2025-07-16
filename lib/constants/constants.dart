class AppConstants {
  // 그리드 관련 상수
  static const int daysInGrid = 365; // 1년
  static const int daysInWeek = 7;
  
  // 반응형 그리드 크기
  static const double gridCellSizeMobile = 10.0;
  static const double gridCellSizeTablet = 14.0;
  static const double gridCellSizeDesktop = 18.0;
  
  static const double gridCellSpacingMobile = 1.5;
  static const double gridCellSpacingTablet = 2.0;
  static const double gridCellSpacingDesktop = 3.0;
  
  static const double gridCellRadius = 2.0;
  
  // 화면 크기 브레이크포인트
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  
  // 반응형 헬퍼 메서드
  static double getGridCellSize(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return gridCellSizeMobile;
    } else if (screenWidth < tabletBreakpoint) {
      return gridCellSizeTablet;
    } else {
      return gridCellSizeDesktop;
    }
  }
  
  static double getGridCellSpacing(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return gridCellSpacingMobile;
    } else if (screenWidth < tabletBreakpoint) {
      return gridCellSpacingTablet;
    } else {
      return gridCellSpacingDesktop;
    }
  }
  
  // 카드 관련 상수
  static const double cardBorderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double cardPadding = 16.0;
  
  // 애니메이션 상수
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  
  // 스페이싱 상수
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  
  // 데이터베이스 상수
  static const String habitBoxName = 'habits';
  static const String settingsBoxName = 'settings';
  
  // 날짜 형식
  static const String dateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'M월 d일';
  static const String monthFormat = 'yyyy년 M월';
}