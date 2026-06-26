import 'package:flutter/material.dart';
import 'package:velocity/data/format_registry.dart';

class FormatSelectorButton extends StatefulWidget {
  final String? singleExtension;       // Pass this for single file mode
  final List<String>? batchExtensions; // Pass this for universal mode
  final String? initialValue;          // Tracks parent state changes
  final Function(String) onFormatSelected;

  const FormatSelectorButton({
    super.key,
    this.singleExtension,
    this.batchExtensions,
    this.initialValue,
    required this.onFormatSelected,
  });

  @override
  State<FormatSelectorButton> createState() => _FormatSelectorButtonState();
}

class _FormatSelectorButtonState extends State<FormatSelectorButton> {
  
  // Compute what options are available based on inputs passed down
  Map<String, List<String>> _getAvailableOptions() {
    List<String> flatTargets = [];

    if (widget.batchExtensions != null && widget.batchExtensions!.isNotEmpty) {
      // Universal Batch Mode
      flatTargets = FormatRegistry.getCommonTargets(widget.batchExtensions!);
    } else if (widget.singleExtension != null) {
      // Single File Mode
      flatTargets = FormatRegistry.getTargets(widget.singleExtension!);
    }

    // Convert flat targets ['jpg', 'pdf'] into categorized structure
    return FormatRegistry.getCategorizedTargets(flatTargets);
  }

  void _showMultiLayerDropdown(BuildContext context, Map<String, List<String>> currentData) {
    if (currentData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No compatible conversions found for selection.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xff1a1a1e),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            padding: const EdgeInsets.all(12),
            width: 280,
            height: 350,
            child: MultiLayerMenu(
              data: currentData,
              onItemSelected: (item) {
                // Pass the selection up to the parent right away
                widget.onFormatSelected(item);
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final computedOptions = _getAvailableOptions();
    
    // Determine the label text dynamically based on incoming parent properties
    final buttonText = widget.initialValue ?? "Convert to";

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff2a2a30),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      onPressed: () => _showMultiLayerDropdown(context, computedOptions),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(buttonText),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 18),
        ],
      ),
    );
  }
}

// Child drill-down list remains straightforward
class MultiLayerMenu extends StatefulWidget {
  final Map<String, List<String>> data;
  final Function(String) onItemSelected;

  const MultiLayerMenu({super.key, required this.data, required this.onItemSelected});

  @override
  State<MultiLayerMenu> createState() => _MultiLayerMenuState();
}

class _MultiLayerMenuState extends State<MultiLayerMenu> {
  String? currentCategory;

  @override
  Widget build(BuildContext context) {
    if (currentCategory != null) {
      final subItems = widget.data[currentCategory] ?? [];
      return Column(
        children: [
          ListTile(
            horizontalTitleGap: 4,
            leading: const Icon(Icons.arrow_back, color: Colors.redAccent, size: 20),
            title: Text(currentCategory!, style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => setState(() => currentCategory = null),
          ),
          const Divider(color: Colors.white10),
          Expanded(
            child: ListView.builder(
              itemCount: subItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(subItems[index]),
                  onTap: () => widget.onItemSelected(subItems[index]),
                );
              },
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text("Select Type", style: TextStyle(color: Colors.grey)),
        ),
        const Divider(color: Colors.white10),
        Expanded(
          child: ListView.builder(
            itemCount: widget.data.keys.length,
            itemBuilder: (context, index) {
              String category = widget.data.keys.elementAt(index);
              return ListTile(
                title: Text(category),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                onTap: () => setState(() => currentCategory = category),
              );
            },
          ),
        ),
      ],
    );
  }
}