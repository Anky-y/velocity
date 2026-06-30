import 'package:flutter/material.dart';
import 'package:velocity/core/theme/app_colors.dart';
import 'package:velocity/screens/homePage.dart';

import 'package:velocity/test/test_ui_runner.dart';
import 'package:velocity/core/theme/app_colors.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentThemeMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: currentThemeMode,
          home: HomePage(),
        );
      },
    );
  }
}
