import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../utils/theme.dart';
import '../utils/responsive_web_utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWebUtils.isMobile(context);

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
      actions: isMobile ? _buildMobileActions(context) : _buildDesktopActions(context),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  List<Widget> _buildDesktopActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => _navigateTo(context, AppRoutes.landing),
        child: const Text(
          'Home',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      TextButton(
        onPressed: () => _navigateTo(context, AppRoutes.featured),
        child: const Text(
          'Featured Projects',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      PopupMenuButton<String>(
        onSelected: (route) => _navigateTo(context, route),
        color: AppColors.skyDark,
        offset: const Offset(0, kToolbarHeight),
        itemBuilder: (context) {
          final genericEntries = _buildGenericPageEntries();
          if (genericEntries.isEmpty) {
            return [
              PopupMenuItem<String>(
                value: '',
                enabled: false,
                child: _menuItemText('No pages available'),
              ),
            ];
          }
          return genericEntries;
        },
        child: const Center(
          child: Text(
            'Projects',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      const SizedBox(width: 16),
    ];
  }

  List<Widget> _buildMobileActions(BuildContext context) {
    return [
      PopupMenuButton<String>(
        onSelected: (route) {
          if (route.isEmpty) return;
          _navigateTo(context, route);
        },
        color: AppColors.skyDark,
        offset: const Offset(0, kToolbarHeight),
        itemBuilder: (context) {
          final items = <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: AppRoutes.landing,
              child: _menuItemText('Home'),
            ),
            PopupMenuItem<String>(
              value: AppRoutes.featured,
              child: _menuItemText('Featured Projects'),
            ),
          ];

          final genericEntries = _buildGenericPageEntries();
          if (genericEntries.isNotEmpty) {
            items.add(const PopupMenuDivider());
            items.addAll(genericEntries);
          }

          return items;
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            'Pages',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      const SizedBox(width: 8),
    ];
  }

  List<PopupMenuEntry<String>> _buildGenericPageEntries() {
    if (AppRoutes.genericPageSlugs.isEmpty) {
      return <PopupMenuEntry<String>>[];
    }

    return AppRoutes.genericPageSlugs.entries
        .map(
          (entry) => PopupMenuItem<String>(
            value: AppRoutes.pagePath(entry.key),
            child: _menuItemText(entry.value),
          ),
        )
        .toList();
  }

  Text _menuItemText(String label) {
    return Text(
      label,
      style: const TextStyle(color: Colors.white),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    if (route.isEmpty) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (r) => false,
    );
  }
}
