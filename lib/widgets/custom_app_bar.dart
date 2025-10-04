import 'package:flutter/material.dart';
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

        // Projects dropdown: Programming Projects (all) and Translations Projects
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'programming') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.projects,
                (route) => false,
              );
            } else if (value == 'translations') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.japaneseTranslations,
                (route) => false,
              );
            }
          },
          color: AppColors.skyDark,
          offset: const Offset(0, kToolbarHeight),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'programming',
              child: Text('Programming Projects', style: TextStyle(color: Colors.white)),
            ),
            const PopupMenuItem(
              value: 'translations',
              child: Text('Translations Projects', style: TextStyle(color: Colors.white)),
            ),
          ],
          child: Center(
            child: Text(
              'Projects',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}