import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/habit_provider.dart';
import 'screens/home_screen.dart';
import 'constants/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // HabitProvider 인스턴스 생성 및 Hive 초기화
  final habitProvider = HabitProvider();
  await habitProvider.initHive();
  
  runApp(MyApp(habitProvider: habitProvider));
}

class MyApp extends StatelessWidget {
  final HabitProvider habitProvider;
  
  const MyApp({super.key, required this.habitProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: habitProvider,
      child: MaterialApp(
        title: 'Habit Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.dark(
            primary: AppColors.primaryColor,
            secondary: AppColors.primaryColor,
            background: AppColors.backgroundColor,
            surface: AppColors.cardColor,
            onPrimary: AppColors.textPrimary,
            onSecondary: AppColors.textPrimary,
            onBackground: AppColors.textPrimary,
            onSurface: AppColors.textPrimary,
            outline: AppColors.borderColor,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.backgroundColor,
          cardTheme: CardTheme(
            color: AppColors.cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.backgroundColor,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}