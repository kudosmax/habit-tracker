# 🌱 Habit Tracker

GitHub 스타일 잔디 그래프로 습관을 시각적으로 추적하는 Flutter 앱

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

## ✨ 주요 기능

### 🎯 **핵심 기능**
- **GitHub 잔디 스타일** 연간 시각화 (365일 그리드)
- **원터치 체크인** - 빠른 습관 완료 표시
- **과거 날짜 수정** - 그리드를 터치해서 기록 수정
- **연속 기록(Streak)** 자동 계산
- **8가지 색상 팔레트** - 습관별 구분

### 📱 **iOS 홈 스크린 위젯**
- **Medium 위젯**: 습관명 + 최근 15일 잔디 + 체크 버튼
- **실시간 동기화**: 앱과 위젯 간 자동 데이터 업데이트
- **원터치 토글**: 위젯에서 바로 오늘 습관 완료 표시

### 💾 **오프라인 우선**
- **Hive 로컬 데이터베이스** - 계정 없이 사용
- **Provider 상태 관리** - 실시간 UI 업데이트
- **타임존 안전** 날짜 처리

## 📸 스크린샷

### 메인 화면
- 습관 카드 리스트 (가로로 긴 형태)
- 각 카드에 축약된 잔디 그리드 (90일)
- 오늘 체크박스 + 기본 통계

### 상세 화면  
- 365일 전체 GitHub 스타일 그리드
- 터치로 과거 날짜 수정 가능
- 연속 기록, 총 완료일, 월별 통계

### 습관 추가
- 간단한 이름 입력
- 8가지 프리셋 색상 선택
- 실시간 미리보기

## 🏗️ 아키텍처

```
lib/
├── models/          # Hive 데이터 모델
├── providers/       # Provider 상태 관리
├── screens/         # UI 화면들
├── widgets/         # 재사용 가능한 위젯
├── services/        # iOS 위젯 서비스
├── utils/           # 날짜 유틸리티
└── constants/       # 색상, 상수 정의
```

### 핵심 컴포넌트
- **`HabitGrid`**: GitHub 스타일 잔디 그리드 위젯
- **`HabitCard`**: 메인 화면용 축약 카드
- **`WidgetService`**: iOS 위젯 데이터 동기화
- **`DateHelper`**: 타임존 안전 날짜 처리

## 🚀 시작하기

### 필요 조건
- Flutter 3.22.0+
- Dart 3.4.0+
- iOS 14+ (위젯 사용 시)

### 설치
```bash
git clone https://github.com/kudosmax/habit-tracker.git
cd habit-tracker
flutter pub get
dart run build_runner build
flutter run
```

### iOS 위젯 설정 (선택사항)
1. Xcode에서 Widget Extension 추가
2. App Group 설정 (`group.com.habittracker.app`)
3. 앱 설정에서 위젯 권한 요청

## 📊 데이터 구조

### Habit 모델
```dart
@HiveType(typeId: 0)
class Habit extends HiveObject {
  String id;                    // 고유 ID
  String name;                  // 습관명
  int colorValue;              // 색상값
  DateTime createdAt;          // 생성일
  List<String> completedDates; // 완료된 날짜들
  
  // Helper methods
  int get currentStreak;       // 현재 연속 기록
  int get totalCompletedDays;  // 총 완료일 수
  bool isCompletedOn(DateTime date); // 특정 날짜 완료 여부
  void toggleDate(DateTime date);    // 날짜 토글
}
```

## 🎨 디자인 시스템

### 색상 팔레트
- 🟠 오렌지 (기본) - `#FFB347`
- 🟢 그린 - `#4CAF50`  
- 🔵 블루 - `#2196F3`
- 🟣 퍼플 - `#9C27B0`
- 🔴 딥 오렌지 - `#FF5722`
- ⚫ 블루 그레이 - `#607D8B`
- 🩷 핑크 - `#E91E63`
- 🤎 브라운 - `#795548`

### GitHub 잔디 그리드
- **빈 날**: 연한 회색 (`#EBEDF0`)
- **완료일**: 선택한 습관 색상
- **오늘**: 파란색 테두리 강조
- **셀 크기**: 12x12px, 간격 2px

## 🛠️ 개발 현황

### ✅ 완성된 기능
- [x] 기본 습관 CRUD
- [x] GitHub 스타일 잔디 그리드
- [x] 인터랙티브 날짜 편집
- [x] 연속 기록 계산
- [x] iOS 위젯 인프라
- [x] 로컬 데이터 저장
- [x] 설정 화면

### 🚧 향후 계획
- [ ] 푸시 알림
- [ ] 데이터 백업/복원  
- [ ] 다크 모드
- [ ] 습관 카테고리
- [ ] 주간 목표 설정
- [ ] 성취 배지 시스템

## 📱 지원 플랫폼

- **iOS** 14+ (위젯 지원)
- **Android** API 21+
- **Web** (개발/테스트용)
- **macOS** (개발/테스트용)

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 🙏 감사인사

- GitHub의 contribution graph에서 영감을 받았습니다
- Flutter 커뮤니티의 훌륭한 패키지들을 활용했습니다
- [home_widget](https://pub.dev/packages/home_widget) 패키지로 iOS 위젯 구현

---

⭐ 이 프로젝트가 도움이 되었다면 Star를 눌러주세요!

🐛 버그 리포트나 기능 제안은 [Issues](https://github.com/kudosmax/habit-tracker/issues)에서 환영합니다!