import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_grid.dart';
import '../screens/habit_detail_screen.dart';
import '../utils/date_utils.dart';
import '../constants/constants.dart';
import '../constants/colors.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;

  const HabitCard({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    bool isTodayCompleted = habit.isCompletedOn(DateTime.now());
    
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        onTap: () => _navigateToDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.cardPadding),
          child: Row(
            children: [
              // 왼쪽: 습관 정보 및 체크박스
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // 오늘 체크박스
                        GestureDetector(
                          onTap: () => _toggleToday(context),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isTodayCompleted 
                                  ? habit.color 
                                  : Colors.transparent,
                              border: Border.all(
                                color: habit.color,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: isTodayCompleted 
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingSM),
                        // 습관명
                        Expanded(
                          child: Text(
                            habit.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingSM),
                    // 통계 정보
                    _buildStatsRow(context),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingMD),
              // 오른쪽: 주요 통계 숫자
              _buildMainStats(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    int currentStreak = habit.currentStreak;
    int totalDays = habit.totalCompletedDays;
    int thisMonthDays = habit.getCompletedDaysInMonth(DateTime.now());

    return Row(
      children: [
        _buildStatItem(
          context,
          icon: Icons.local_fire_department,
          value: '$currentStreak',
          label: '연속',
          color: currentStreak > 0 ? Colors.orange : AppColors.textSecondary,
        ),
        const SizedBox(width: AppConstants.spacingMD),
        _buildStatItem(
          context,
          icon: Icons.calendar_month,
          value: '$thisMonthDays',
          label: '이번달',
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildMainStats(BuildContext context) {
    int totalDays = habit.totalCompletedDays;
    double completionRate = 0.0;
    
    int daysSinceCreation = DateTime.now().difference(habit.createdAt).inDays + 1;
    if (daysSinceCreation > 0) {
      completionRate = (totalDays / daysSinceCreation) * 100;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 총 완료 일수
        Text(
          '$totalDays일',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: habit.color,
          ),
        ),
        const SizedBox(height: 2),
        // 완료율
        Text(
          '${completionRate.toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _toggleToday(BuildContext context) {
    Provider.of<HabitProvider>(context, listen: false)
        .toggleHabitDate(habit.id, DateTime.now());
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitDetailScreen(habit: habit),
      ),
    );
  }
}