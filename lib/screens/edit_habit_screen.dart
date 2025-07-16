import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../constants/colors.dart';
import '../constants/constants.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit habit;

  const EditHabitScreen({
    super.key,
    required this.habit,
  });

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  late TextEditingController _nameController;
  late Color _selectedColor;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit.name);
    _selectedColor = widget.habit.color;
    
    // 변경사항 감지를 위한 리스너 추가
    _nameController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    final nameChanged = _nameController.text.trim() != widget.habit.name;
    final colorChanged = _selectedColor != widget.habit.color;
    
    setState(() {
      _hasChanges = nameChanged || colorChanged;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          return await _showDiscardChangesDialog();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('습관 편집'),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : (_hasChanges ? _saveChanges : null),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      '저장',
                      style: TextStyle(
                        color: _hasChanges 
                            ? AppColors.primaryColor 
                            : AppColors.textSecondary,
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
              // 습관명 입력 섹션
              _buildNameSection(),
              const SizedBox(height: AppConstants.spacingXL),
              
              // 색상 선택 섹션
              _buildColorSection(),
              
              const Spacer(),
              
              // 미리보기 카드
              _buildPreviewCard(),
              
              const SizedBox(height: AppConstants.spacingLG),
              
              // 하단 버튼들
              _buildBottomButtons(),
              
              const SizedBox(height: AppConstants.spacingMD),
            ],
          ),
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
            fillColor: AppColors.surfaceColor,
          ),
          textCapitalization: TextCapitalization.sentences,
          maxLength: 20,
          onChanged: (value) {
            _checkForChanges();
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
            Color color = entry.value;
            bool isSelected = color == _selectedColor;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
                _checkForChanges();
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                  border: isSelected 
                      ? Border.all(color: AppColors.textPrimary, width: 3)
                      : Border.all(color: AppColors.borderColor, width: 1),
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
      habitName = '습관 이름';
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
                // 통계 영역
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.habit.totalCompletedDays}일',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _selectedColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${DateTime.now().difference(widget.habit.createdAt).inDays + 1}일째',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMD),
              side: BorderSide(color: AppColors.borderColor),
            ),
            child: const Text('취소'),
          ),
        ),
        const SizedBox(width: AppConstants.spacingMD),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : (_hasChanges ? _saveChanges : null),
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasChanges ? AppColors.primaryColor : AppColors.borderColor,
              padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMD),
            ),
            child: Text(
              '저장',
              style: TextStyle(
                color: _hasChanges ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> _showDiscardChangesDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('변경사항 버리기'),
        content: const Text('저장하지 않은 변경사항이 있습니다. 정말로 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('나가기'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _saveChanges() async {
    String habitName = _nameController.text.trim();
    
    // 유효성 검증
    if (habitName.isEmpty) {
      _showErrorSnackBar('습관 이름을 입력해주세요');
      return;
    }

    if (habitName.length > 20) {
      _showErrorSnackBar('습관 이름은 20자 이하로 입력해주세요');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 습관 정보 업데이트
      final updatedHabit = widget.habit;
      updatedHabit.name = habitName;
      updatedHabit.colorValue = _selectedColor.value;

      await Provider.of<HabitProvider>(context, listen: false)
          .updateHabit(updatedHabit);

      if (mounted) {
        Navigator.pop(context, true); // 성공 여부를 반환
        _showSuccessSnackBar('습관이 수정되었습니다');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('습관 수정에 실패했습니다');
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