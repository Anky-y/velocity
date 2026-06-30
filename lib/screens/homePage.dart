import 'package:flutter/material.dart';
import 'package:velocity/core/theme/app_colors.dart';
import 'package:velocity/data/operation_type_data.dart';
import 'package:velocity/models/fileOperationModel.dart';
import 'package:velocity/screens/SettingsPage.dart';
import 'package:velocity/screens/filePickerPage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // print("BUILD: ${Theme.of(context).brightness}");

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text("Velocity".toUpperCase()),
        centerTitle: true,
      ),
      body: homeBody(context),
      bottomNavigationBar: bottomNavBar(context, 0),
    );
  }

  SingleChildScrollView homeBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 12, right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heroText(),
                Column(
                  children: List.generate(operationTypes.length, (index) {
                    final item = operationTypes[index];
                    return operationTypeCard(context, item);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding operationTypeCard(BuildContext context, OperationType item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FilePickerPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Start",
                    style: TextStyle(
                      fontFamily: 'JetBrainsMonoVariable',
                      fontSize: 20,
                      fontVariations: const <FontVariation>[
                        FontVariation('wght', 400.0),
                        // Custom weight between 100.0 and 900.0
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              item.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'JetBrainsMonoVariable',
                fontVariations: const <FontVariation>[
                  FontVariation('wght', 200.0),
                  // Custom weight between 100.0 and 900.0
                ],
              ),
            ),

            const SizedBox(height: 8),

            Text(
              item.description,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
                height: 1.4,
                fontFamily: "InterVariable",
                fontVariations: const <FontVariation>[
                  FontVariation('wght', 500.0),
                  // Custom weight between 100.0 and 900.0
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding heroText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFDAE2FD), Color(0xFF86F2E4)],
            ).createShader(bounds),
            child: Text(
              "Accelerate your workflow",
              style: TextStyle(
                fontFamily: 'JetBrainsMonoVariable',
                fontSize: 25,
                fontVariations: const <FontVariation>[
                  FontVariation('wght', 700.0),
                  // Custom weight between 100.0 and 900.0
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Choose a powerful utility tool to process your files",
            style: TextStyle(
              fontFamily: 'InterVariable',
              fontSize: 18,
              fontVariations: const <FontVariation>[
                FontVariation('wght', 500.0),
                // Custom weight between 100.0 and 900.0
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Container bottomNavBar(BuildContext context, int currentIndex) {
  return Container(
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: Color(0xFF45464D), width: 0.5)),
    ),
    child: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) {if (index == currentIndex) return; 

        if (index == 0) {
          // Home Tab
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (index == 1) {
          // Recent Tab (Placeholder print statement)
          print("Recents tab tapped!");
        } else if (index == 2) {
          // Settings Tab
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "Recent"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    ),
  );
}
