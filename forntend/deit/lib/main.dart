// lib/main.dart

import 'package:deit/result.dart';
import 'package:deit/screens/main_selection_screen.dart';
import 'package:deit/screens/select_goal.dart';
import 'package:deit/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';
import 'models/plan.dart';
import 'screens/plan_choice.dart';
import 'screens/user_form.dart';
import 'screens/plan_generator.dart';
import 'screens/custom_target.dart';
import 'screens/meal_filter.dart';
import 'screens/fitness_plan_screen.dart';
// import 'screens/selection_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserModel()),
        ChangeNotifierProvider(create: (_) => PlanModel()),
      ],
      child: MealPlannerApp(),
    ),
  );
}

class MealPlannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (_) => WelcomeScreen(),
        '/': (_) => MainSelectionScreen(),
        '/choose': (_) => PlanChoiceScreen(),
        '/user': (_) => UserFormScreen(),
        '/generator': (_) => PlanGeneratorScreen(),
        '/custom_target': (_) => CustomTargetScreen(),
        '/plan': (_) => MealFilterScreen(),
        '/fitness': (_) => FitnessPlanScreen(),
        '/select-goal': (context) => SelectGoalScreen(),
        '/result': (context) => ResultScreen(),
      },
    );
  }
}
