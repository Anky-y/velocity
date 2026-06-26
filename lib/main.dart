import 'package:flutter/material.dart';
import 'package:velocity/core/theme/app_colors.dart';
import 'package:velocity/screens/filePickerPage.dart';
import 'package:velocity/screens/homePage.dart';


void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: HomePage(),
    );
  }
}
