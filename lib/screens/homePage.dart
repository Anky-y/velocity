import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:velocity/data/category_type_data.dart';
import 'package:velocity/data/quick_acess_data.dart';
import 'package:velocity/data/recent_file_data.dart';
import 'package:velocity/models/recent_file_item.dart';
import 'package:velocity/screens/conversionList.dart';
import '../core/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.background,
      appBar: AppBar(
        title: const Text("Velocity"),
        backgroundColor: LightColors.background,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            searchBar(context),
            quickAccess(),
            categories(context),
            recentFiles(),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavBar(),
    );
  }

  BottomNavigationBar BottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "Recent"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }

  Padding recentFiles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "RECENT FILES",
                  style: TextStyle(
                    fontFamily: 'JetBrainsMonoVariable',
                    fontSize: 20,
                    fontVariations: const <FontVariation>[
                      FontVariation('wght', 650.0),
                      // Custom weight between 100.0 and 900.0
                    ],
                  ),
                ),
              ),
              Text(
                "View All",
                style: TextStyle(
                  fontFamily: 'JetBrainsMonoVariable',
                  fontSize: 20,
                  color: LightColors.primary,
                  fontVariations: const <FontVariation>[
                    FontVariation('wght', 650.0),
                    // Custom weight between 100.0 and 900.0
                  ],
                ),
              ),
            ],
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: RecentFilesData.items.length,
            itemBuilder: (context, index) {
              final item = RecentFilesData.items[index];
              return Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: LightColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: LightColors.mutedText.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: FaIcon(item.icon, color: item.color),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontFamily: 'InterVariable',
                              fontSize: 16,
                              fontVariations: const <FontVariation>[
                                FontVariation('wght', 600.0),
                                // Custom weight between 100.0 and 900.0
                              ],
                            ),
                          ),
                          Text(
                            'Converted from ${item.convertedFrom} • ${timeAgo(item.time)}',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMonoVariable',
                              fontSize: 10,
                              fontVariations: const <FontVariation>[
                                FontVariation('wght', 500.0),
                                // Custom weight between 100.0 and 900.0
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download_outlined),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 5),
          ),
        ],
      ),
    );
  }

  Padding categories(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              "CATEGORIES",
              style: TextStyle(
                fontFamily: 'JetBrainsMonoVariable',
                fontSize: 20,
                fontVariations: const <FontVariation>[
                  FontVariation('wght', 650.0),
                  // Custom weight between 100.0 and 900.0
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemCount: CategoryTypeData.items.length,
              itemBuilder: (context, index) {
                final item = CategoryTypeData.items[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ConversionListScreen(
                              selectedCategory: item.category,
                            ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              // Smooth slide upwards and fade transition
                              const begin = Offset(0.0, 0.1);
                              const end = Offset.zero;
                              const curve = Curves.easeOutCubic;

                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);

                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                ),
                              );
                            },
                        transitionDuration: const Duration(milliseconds: 350),
                      ),
                    );
                  },
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: LightColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Center(child: FaIcon(item.icon)),
                        ),
                        Text(
                          item.name,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding quickAccess() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              "QUICK ACCESS",
              style: TextStyle(
                fontFamily: 'JetBrainsMonoVariable',
                fontSize: 20,
                fontVariations: const <FontVariation>[
                  FontVariation('wght', 650.0),
                  // Custom weight between 100.0 and 900.0
                ],
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(width: 12),
              itemCount: QuickAccessData.items.length,
              itemBuilder: (context, index) {
                final item = QuickAccessData.items[index];

                return Padding(
                  padding: const EdgeInsets.only(top: 25, bottom: 25),
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                      color: LightColors.surface,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(item.icon, color: item.color, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          item.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'InterVariable',
                            fontVariations: const <FontVariation>[
                              FontVariation('wght', 600.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Container searchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search conversions, e.g., 'PDF to DOCX'",
            prefixIcon: const Icon(Icons.search, color: LightColors.primary),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

String timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);

  if (diff.inSeconds < 60) {
    return "just now";
  } else if (diff.inMinutes < 60) {
    return "${diff.inMinutes}m ago";
  } else if (diff.inHours < 24) {
    return "${diff.inHours}h ago";
  } else if (diff.inDays < 7) {
    return "${diff.inDays}d ago";
  } else {
    return "${time.day}/${time.month}/${time.year}";
  }
}
