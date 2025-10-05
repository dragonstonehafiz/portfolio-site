import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../routes/app_routes.dart';
import '../utils/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Muhd Hafiz\'s Portfolio',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.skyDark,
      elevation: 4,
      centerTitle: false,
      actions: [
        TextButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.landing,
            (route) => false,
          ),
          child: const Text(
            'Home',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.featured,
            (route) => false,
          ),
          child: const Text(
            'Featured Projects',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),

        // Projects dropdown: populated from page_config.json generic pages.
        PopupMenuButton<String>(
          onSelected: (value) {
            // Expect value to be the page_name string (human readable). Map
            // it to a slug path via AppRoutes.pagePath(slug) if needed.
            // First, try to find a slug key for the selected page name.
            final slugEntry = AppRoutes.genericPageSlugs.entries
                .firstWhere((e) => e.value == value, orElse: () => const MapEntry('', ''));
            if (slugEntry.key.isNotEmpty) {
              final targetPath = AppRoutes.pagePath(slugEntry.key);
              Navigator.pushNamedAndRemoveUntil(
                context,
                targetPath,
                (route) => false,
              );
              return;
            }

            debugPrint('No slug mapping found for: $value');
          },
          color: AppColors.skyDark,
          offset: const Offset(0, kToolbarHeight),
          itemBuilder: (context) {
            final items = <PopupMenuEntry<String>>[];
            if (AppRoutes.genericPageSlugs.isNotEmpty) {
              for (final entry in AppRoutes.genericPageSlugs.entries) {
                items.add(PopupMenuItem(
                  value: entry.value,
                  child: Text(entry.value, style: const TextStyle(color: Colors.white)),
                ));
              }
            } else {
              items.add(const PopupMenuItem(value: 'cooked', child: Text('cooked custom_app_bar.dart', style: TextStyle(color: Colors.white))));
            }
            return items;
          },
          child: Center(
            child: Text(
              'Projects',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}