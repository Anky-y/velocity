import 'package:flutter/material.dart';
import 'package:velocity/models/conversionListModel.dart';

class ConversionPage extends StatelessWidget {
  const ConversionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final option = ModalRoute.of(context)!.settings.arguments as ConversionOption;

    return Scaffold(
      appBar: AppBar(
        title: Text(option.title),
      ),
      body: const SizedBox.shrink(), 
    );
  }
}