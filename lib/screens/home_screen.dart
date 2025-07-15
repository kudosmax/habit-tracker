import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import '../utils/date_utils.dart';
import 'add_habit_screen.dart';
import 'settings_screen.dart';
import '../constants/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Habit Tracker'),
            Consumer<HabitProvider>(
              builder: (context, provider, child) {
                return Text(
                  '${DateHelper.formatDisplayDate(DateTime.now())} • ${provider.todayCompletedCount}/${provider.totalHabitsCount}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateToSettings(context),
          ),
        ],
      ),
      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          if (habitProvider.habits.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            itemCount: habitProvider.habits.length,
            itemBuilder: (context, index) {
              final habit = habitProvider.habits[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingMD),
                child: HabitCard(habit: habit),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddHabit(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.track_changes,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppConstants.spacingLG),
          Text(
            '첫 번째 습관을 만들어보세요!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            '매일의 성취를 시각적으로\n확인하고 관리해보세요',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: AppConstants.spacingXL),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddHabit(context),
            icon: const Icon(Icons.add),
            label: const Text('습관 추가하기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLG,
                vertical: AppConstants.spacingMD,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddHabit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddHabitScreen(),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
}