import 'package:flutter/material.dart';
import 'package:velocity/data/recent_file_service.dart';
import 'package:velocity/models/recentFileModel.dart';

class RecentFilesPage extends StatelessWidget {
  const RecentFilesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recent Files")),
      body: FutureBuilder<List<RecentFile>>(
        future: RecentFilesService().getValidRecents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final recents = snapshot.data ?? [];
          if (recents.isEmpty) {
            return const Center(child: Text("No recent downloads found."));
          }

          return ListView.builder(
            itemCount: recents.length,
            itemBuilder: (context, index) {
              final item = recents[index];
              return ListTile(
                leading: Icon(
                  item.fileMediaType == 'image'
                      ? Icons.image
                      : Icons.video_collection,
                ),
                title: Text(item.fileName),
                subtitle: Text("${(item.size / 1024).toStringAsFixed(1)} KB"),
                onTap: () {
                  // Open or share the file natively using its item.path variable
                },
              );
            },
          );
        },
      ),
    );
  }
}
