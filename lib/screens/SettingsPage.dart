import 'package:flutter/material.dart';
import 'package:velocity/core/theme/app_colors.dart';
import 'package:velocity/data/operation_type_data.dart';
import 'package:velocity/models/fileOperationModel.dart';
import 'package:velocity/screens/filePickerPage.dart';
import 'package:velocity/screens/homePage.dart';
import 'package:velocity/main.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Velocity".toUpperCase()),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        children: [
          // 1. Title Block (Inherits InterVariable & layout details naturally)
          Text(
            "Settings",
            style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 24),

          // 2. GENERAL SECTION
          Text(
            "GENERAL",
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer, 
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline, width: 1),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
                  title: Text("Theme", style: theme.textTheme.bodyLarge),
                  subtitle: Text(
    theme.brightness == Brightness.dark ? "Dark" : "Light", 
    style: theme.textTheme.bodySmall,
  ),
                  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.outline),
                  onTap: () => _showThemeDialog(context),
                ),
                Divider(color: theme.colorScheme.outline, height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.language, color: theme.colorScheme.primary),
                  title: Text("Language", style: theme.textTheme.bodyLarge),
                  subtitle: Text("English (US)", style: theme.textTheme.bodySmall),
                  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.outline),
                  onTap: () {
                    print("Language picker clicked");
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // 3. SUPPORT SECTION
          Text(
            "SUPPORT",
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline, width: 1),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.help_outline, color: theme.colorScheme.primary),
                  title: Text("Help Center", style: theme.textTheme.bodyLarge),
                  subtitle: Text("FAQs & Guides", style: theme.textTheme.bodySmall),
                  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.outline),
                  onTap: () {
                    print("Help Center clicked");
                  },
                ),
                Divider(color: theme.colorScheme.outline, height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
                  title: Text("About Velocity", style: theme.textTheme.bodyLarge),
                  subtitle: Text("Version 2.4.1", style: theme.textTheme.bodySmall),
                  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.outline),
                  onTap: () {
                    print("About Screen clicked");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      // Active Selection is at index 2 (Settings)
      bottomNavigationBar: bottomNavBar(context, 2), 
    );
  }
}


void _showThemeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choose Theme",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.wb_sunny_outlined),
                title: const Text("Light Mode"),
                onTap: () {
                  themeNotifier.value = ThemeMode.light;
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.nightlight_round_outlined),
                title: const Text("Dark Mode"),
                onTap: () {
                  themeNotifier.value = ThemeMode.dark;
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_auto_outlined),
                title: const Text("System Default"),
                onTap: () {
                  themeNotifier.value = ThemeMode.system;
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }