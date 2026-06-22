import 'package:flutter/material.dart';
import 'package:velocity/data/conversion_data.dart';
import 'package:velocity/models/conversionListModel.dart';
import 'package:velocity/screens/conversionPage.dart';

class ConversionListScreen extends StatelessWidget {
  final FileTypeCategory selectedCategory; 

  const ConversionListScreen({
    super.key, 
    required this.selectedCategory, 
  });

  @override
  Widget build(BuildContext context) {
    
    final config = ConversionData.registry[selectedCategory];
    if (config == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(
          child: Text("No conversion options found for this category."),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(config.pageTitle),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: ListView.builder(
        itemCount: config?.options.length,
        itemBuilder: (BuildContext context, int index) {
          final option = config?.options[index];

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: option?.iconColor.withAlpha(30),
                child: Icon(option?.icon, color: option?.iconColor),
              ),
              title: Text(
                option!.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(option.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConversionPage(),
                    // This line attaches the argument payload to this specific route transition instance
                    settings: RouteSettings(arguments: option),
                  ),
                );
                print("Tapped on ${option.title}");
              },
            ),
          );
        },
      ),
    );
  }
}
