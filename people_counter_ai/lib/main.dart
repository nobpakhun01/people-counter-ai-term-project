import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/people_provider.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PeopleCounterApp());
}

class PeopleCounterApp extends StatelessWidget {
  const PeopleCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PeopleProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'People Counter AI',
        theme: AppTheme.darkTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
