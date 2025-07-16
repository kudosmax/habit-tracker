import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../constants/constants.dart';
import '../constants/colors.dart';
import '../services/backup_service.dart';
import '../models/habit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        children: [
          _buildWidgetSection(context),
          const SizedBox(height: AppConstants.spacingLG),
          _buildDataSection(context),
          const SizedBox(height: AppConstants.spacingLG),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildWidgetSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.widgets,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.spacingSM),
                Text(
                  'iOS 위젯',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              '간단한 위젯: 습관명 + 활동 기록 + 오늘 체크 버튼',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Consumer<HabitProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.add_to_home_screen),
                      title: const Text('위젯 권한 요청'),
                      subtitle: const Text('홈 화면 위젯 추가를 위한 권한'),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          bool granted = await provider.requestWidgetPermission();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  granted ? '위젯 권한이 허용되었습니다' : '위젯 권한이 거부되었습니다',
                                ),
                                backgroundColor: granted ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text('요청'),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('위젯 설정 방법'),
                      subtitle: const Text('iPhone 홈 화면에서 위젯 추가하기'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showWidgetSetupInstructions(context),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.spacingSM),
                Text(
                  '데이터 관리',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Consumer<HabitProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.backup),
                      title: const Text('데이터 백업'),
                      subtitle: Text('${provider.totalHabitsCount}개 습관 백업'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _performBackup(context, provider),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.restore),
                      title: const Text('데이터 복원'),
                      subtitle: const Text('백업 파일에서 복원'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _performRestore(context, provider),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.upload_file),
                      title: const Text('습관 데이터 가져오기'),
                      subtitle: const Text('CSV/JSON 파일에서 습관 추가'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _importHabitData(context, provider),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text('모든 데이터 삭제', style: TextStyle(color: Colors.red)),
                      subtitle: const Text('모든 습관과 기록을 영구적으로 삭제'),
                      trailing: const Icon(Icons.chevron_right, color: Colors.red),
                      onTap: () => _showDeleteAllDialog(context),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.spacingSM),
                Text(
                  '앱 정보',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),
            ListTile(
              leading: const Icon(Icons.track_changes),
              title: const Text('Habit Tracker'),
              subtitle: const Text('버전 1.0.0\n시각적 습관 추적 앱'),
              isThreeLine: true,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('개발 정보'),
              subtitle: const Text('Flutter로 개발된 크로스 플랫폼 앱'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWidgetSetupInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위젯 설정 방법'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. iPhone 홈 화면에서 빈 공간을 길게 눌러주세요'),
              SizedBox(height: 8),
              Text('2. 화면 상단의 + 버튼을 탭하세요'),
              SizedBox(height: 8),
              Text('3. "Habit Tracker"를 찾아서 선택하세요'),
              SizedBox(height: 8),
              Text('4. Medium 크기 위젯을 선택하세요'),
              SizedBox(height: 8),
              Text('5. "위젯 추가"를 탭하여 완료하세요'),
              SizedBox(height: 12),
              Text('위젯 기능:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('• 습관명과 현재 연속기록 표시'),
              Text('• 최근 15일 활동 기록 그리드'),
              Text('• 우측 하단 체크 버튼으로 오늘 토글'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature 기능은 곧 추가될 예정입니다')),
    );
  }

  // 데이터 백업 실행
  void _performBackup(BuildContext context, HabitProvider provider) {
    if (provider.habits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('백업할 습관 데이터가 없습니다')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 백업'),
        content: Text(
          '${provider.totalHabitsCount}개의 습관과 모든 기록을 백업하시겠습니까?\n\n'
          '백업 파일은 JSON 형식으로 다운로드됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              BackupService.performBackup(provider.habits);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('백업 파일이 다운로드되었습니다'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('백업'),
          ),
        ],
      ),
    );
  }

  // 데이터 복원 실행
  void _performRestore(BuildContext context, HabitProvider provider) async {
    final hasExistingData = provider.habits.isNotEmpty;
    
    if (hasExistingData) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('데이터 복원'),
          content: const Text(
            '기존 데이터가 있습니다.\n'
            '복원하면 기존 데이터와 백업 데이터가 병합됩니다.\n\n'
            '계속하시겠습니까?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('계속'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
    }

    try {
      final result = await BackupService.importBackupFile();
      
      if (result.success) {
        // 백업 데이터 가져오기 성공
        for (Habit habit in result.habits) {
          await provider.addHabit(habit);
        }
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('복원 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 습관 데이터 가져오기 (CSV/JSON)
  void _importHabitData(BuildContext context, HabitProvider provider) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('습관 데이터 가져오기'),
        content: const Text(
          '다음 형식의 파일을 가져올 수 있습니다:\n\n'
          '• JSON: 전체 백업 파일\n'
          '• CSV: 습관명,날짜1,날짜2,날짜3...\n\n'
          '예시: 운동하기,2024-01-01,2024-01-03,2024-01-05\n\n'
          '파일을 선택하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final result = await BackupService.importBackupFile();
                
                if (result.success) {
                  // 데이터 가져오기 성공
                  for (Habit habit in result.habits) {
                    await provider.addHabit(habit);
                  }
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('가져오기 중 오류가 발생했습니다: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('파일 선택'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 데이터 삭제'),
        content: const Text(
          '정말로 모든 습관과 기록을 삭제하시겠습니까?\n'
          '이 작업은 되돌릴 수 없습니다.\n\n'
          '삭제하기 전에 백업을 권장합니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // 최종 확인
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('⚠️ 최종 확인'),
                  content: const Text(
                    '정말로 모든 데이터를 삭제하시겠습니까?\n'
                    '이 작업은 되돌릴 수 없습니다!',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true) {
                try {
                  await BackupService.deleteAllData(
                    Provider.of<HabitProvider>(context, listen: false)
                  );
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('모든 데이터가 삭제되었습니다'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('삭제 중 오류가 발생했습니다: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}