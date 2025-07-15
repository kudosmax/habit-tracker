import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_grid.dart';
import '../utils/date_utils.dart';
import '../constants/constants.dart';
import '../constants/colors.dart';

class HabitDetailScreen extends StatelessWidget {
  final Habit habit;

  const HabitDetailScreen({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('편집'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('삭제', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 통계 카드들
            _buildStatsCards(context),
            const SizedBox(height: AppConstants.spacingLG),
            
            // GitHub 스타일 그리드
            _buildGridSection(context),
            const SizedBox(height: AppConstants.spacingLG),
            
            // 추가 정보
            _buildAdditionalInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: '연속 기록',
            value: '${habit.currentStreak}일',
            icon: Icons.local_fire_department,
            color: habit.currentStreak > 0 ? Colors.orange : Colors.grey,
          ),
        ),
        const SizedBox(width: AppConstants.spacingMD),
        Expanded(
          child: _buildStatCard(
            context,
            title: '총 완료일',
            value: '${habit.totalCompletedDays}일',
            icon: Icons.check_circle,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: AppConstants.spacingMD),
        Expanded(
          child: _buildStatCard(
            context,
            title: '이번 달',
            value: '${habit.getCompletedDaysInMonth(DateTime.now())}일',
            icon: Icons.calendar_month,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '연간 활동',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppConstants.spacingSM),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: habit.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppColors.getColorName(habit.color),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: habit.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingSM),
        Text(
          '날짜를 터치하여 완료 상태를 변경할 수 있습니다',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMD),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            child: Consumer<HabitProvider>(
              builder: (context, provider, child) {
                // Provider에서 최신 habit 정보를 가져옴
                Habit? updatedHabit = provider.getHabit(habit.id);
                if (updatedHabit == null) {
                  return const Text('습관을 찾을 수 없습니다');
                }
                
                return InteractiveHabitGrid(
                  habit: updatedHabit,
                  onDateTap: (date) {
                    if (!date.isAfter(DateTime.now())) {
                      provider.toggleHabitDate(habit.id, date);
                      _showFeedback(context, updatedHabit.isCompletedOn(date) ? '완료 해제' : '완료 표시');
                    }
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        _buildGridLegend(context),
      ],
    );
  }

  Widget _buildGridLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(context, AppColors.gridEmptyDay, '미완료'),
        const SizedBox(width: AppConstants.spacingMD),
        _buildLegendItem(context, habit.color, '완료'),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '습관 정보',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMD),
            _buildInfoRow(context, '생성일', DateHelper.formatDisplayDate(habit.createdAt)),
            _buildInfoRow(context, '진행 기간', '${DateTime.now().difference(habit.createdAt).inDays + 1}일'),
            if (habit.totalCompletedDays > 0)
              _buildInfoRow(
                context, 
                '완료율', 
                '${((habit.totalCompletedDays / (DateTime.now().difference(habit.createdAt).inDays + 1)) * 100).toStringAsFixed(1)}%'
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        _showEditDialog(context);
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  void _showEditDialog(BuildContext context) {
    // TODO: 편집 기능은 나중에 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('편집 기능은 곧 추가될 예정입니다')),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('습관 삭제'),
        content: Text('\'${habit.name}\' 습관을 삭제하시겠습니까?\n모든 기록이 영구적으로 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<HabitProvider>(context, listen: false)
                  .deleteHabit(habit.id);
              if (context.mounted) {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pop(context); // 상세 화면 닫기
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('습관이 삭제되었습니다'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}