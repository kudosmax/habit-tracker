import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../utils/date_utils.dart';
import '../constants/constants.dart';
import '../constants/colors.dart';

class HabitGrid extends StatelessWidget {
  final Habit habit;
  final int days;
  final bool isInteractive;
  final Function(DateTime)? onDateTap;
  final bool showToday;

  const HabitGrid({
    super.key,
    required this.habit,
    this.days = AppConstants.daysInGrid, // 기본 365일
    this.isInteractive = false,
    this.onDateTap,
    this.showToday = true,
  });

  @override
  Widget build(BuildContext context) {
    List<DateTime> gridDates = DateHelper.generateYearGrid().take(days).toList();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // 그리드 크기 계산
        double availableWidth = constraints.maxWidth;
        int columnsCount = _calculateColumns(availableWidth);
        int rowsCount = (days / columnsCount).ceil();
        
        return SizedBox(
          height: rowsCount * (AppConstants.gridCellSize + AppConstants.gridCellSpacing),
          child: Wrap(
            spacing: AppConstants.gridCellSpacing,
            runSpacing: AppConstants.gridCellSpacing,
            children: gridDates.map((date) {
              return _buildGridCell(date, context);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildGridCell(DateTime date, BuildContext context) {
    bool isCompleted = habit.isCompletedOn(date);
    bool isToday = showToday && DateHelper.isToday(date);
    bool isFuture = date.isAfter(DateTime.now());

    Color cellColor;
    Color borderColor = Colors.transparent;

    if (isFuture) {
      // 미래 날짜는 표시하지 않음
      cellColor = Colors.transparent;
    } else if (isCompleted) {
      cellColor = habit.color;
    } else {
      cellColor = AppColors.gridEmptyDay;
    }

    if (isToday) {
      borderColor = AppColors.gridTodayBorder;
    }

    Widget cell = Container(
      width: AppConstants.gridCellSize,
      height: AppConstants.gridCellSize,
      decoration: BoxDecoration(
        color: cellColor,
        border: isToday ? Border.all(color: borderColor, width: 1.5) : null,
        borderRadius: BorderRadius.circular(AppConstants.gridCellRadius),
      ),
    );

    if (isInteractive && !isFuture && onDateTap != null) {
      return GestureDetector(
        onTap: () => onDateTap!(date),
        child: cell,
      );
    }

    return cell;
  }

  int _calculateColumns(double availableWidth) {
    // 사용 가능한 너비에 따라 컬럼 수 계산
    double cellWithSpacing = AppConstants.gridCellSize + AppConstants.gridCellSpacing;
    int maxColumns = (availableWidth / cellWithSpacing).floor();
    
    // 최소 20개, 최대 53개 컬럼 (GitHub과 유사)
    return maxColumns.clamp(20, 53);
  }
}

// 축약된 그리드 (메인 화면용 - 최근 3개월)
class CompactHabitGrid extends StatelessWidget {
  final Habit habit;
  
  const CompactHabitGrid({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    // 최근 90일만 표시
    return HabitGrid(
      habit: habit,
      days: 90,
      isInteractive: false,
      showToday: true,
    );
  }
}

// 인터랙티브 그리드 (상세 화면용)
class InteractiveHabitGrid extends StatelessWidget {
  final Habit habit;
  final Function(DateTime) onDateTap;

  const InteractiveHabitGrid({
    super.key,
    required this.habit,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return HabitGrid(
      habit: habit,
      days: AppConstants.daysInGrid,
      isInteractive: true,
      onDateTap: onDateTap,
      showToday: true,
    );
  }
}