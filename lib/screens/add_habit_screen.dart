import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../constants/colors.dart';
import '../constants/constants.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _nameController = TextEditingController();
  Color _selectedColor = AppColors.habitColors[0]; // 기본값: 오렌지
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 습관 추가'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveHabit,
            child: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    '저장',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 습관명 입력
            _buildNameSection(),
            const SizedBox(height: AppConstants.spacingXL),
            
            // 색상 선택
            _buildColorSection(),
            
            const Spacer(),
            
            // 미리보기 카드
            _buildPreviewCard(),
            
            const SizedBox(height: AppConstants.spacingLG),
          ],
        ),
      ),
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '습관 이름',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: '예: 운동하기, 독서, 물 마시기',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          textCapitalization: TextCapitalization.sentences,
          maxLength: 20,
          onChanged: (value) {
            setState(() {}); // 미리보기 업데이트
          },
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '색상 선택',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        Text(
          '습관을 구분하기 위한 색상을 선택하세요',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMD),
        Wrap(
          spacing: AppConstants.spacingMD,
          runSpacing: AppConstants.spacingMD,
          children: AppColors.habitColors.asMap().entries.map((entry) {
            int index = entry.key;
            Color color = entry.value;
            bool isSelected = color == _selectedColor;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                  border: isSelected 
                      ? Border.all(color: AppColors.textPrimary, width: 3)
                      : Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        Text(
          '선택된 색상: ${AppColors.getColorName(_selectedColor)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    String habitName = _nameController.text.trim();
    if (habitName.isEmpty) {
      habitName = '새로운 습관';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '미리보기',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.cardPadding),
            child: Row(
              children: [
                // 체크박스
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(color: _selectedColor, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSM),
                // 습관명
                Expanded(
                  child: Text(
                    habitName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMD),
                // 미니 그리드 (빈 상태)
                Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      '활동 기록',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveHabit() async {
    String habitName = _nameController.text.trim();
    
    if (habitName.isEmpty) {
      _showErrorSnackBar('습관 이름을 입력해주세요');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final habit = Habit(
        name: habitName,
        colorValue: _selectedColor.value,
      );

      await Provider.of<HabitProvider>(context, listen: false)
          .addHabit(habit);

      if (mounted) {
        Navigator.pop(context);
        _showSuccessSnackBar('습관이 추가되었습니다!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('습관 추가에 실패했습니다');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}