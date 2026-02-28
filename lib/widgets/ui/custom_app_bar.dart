import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../core/responsive_web_utils.dart';
import '../../data/pages/page_collection.dart';
import '../../data/pages/page_models.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  static const EdgeInsets _navPadding = EdgeInsets.symmetric(horizontal: 12.0);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWebUtils.isMobile(context);

    return Container(
      decoration: BoxDecoration(gradient: Theme.of(context).primaryGradient),
      child: AppBar(
        title: const Text(
          'Muhd Hafiz',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: isMobile
            ? _buildMobileActions(context)
            : _buildDesktopActions(context),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  List<Widget> _buildDesktopActions(BuildContext context) {
    final pages = PageCollection.instance.genericPages;
    final primaryPages = pages.where((p) => !p.dropdown).toList();
    final dropdownPages = pages.where((p) => p.dropdown).toList();

    final navButtonStyle = TextButton.styleFrom(
      padding: _navPadding,
      foregroundColor: Colors.white,
    );
    final navTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return [
      TextButton(
        onPressed: () => _navigateTo(context, AppRoutes.landing),
        style: navButtonStyle,
        child: Text('Home', style: navTextStyle),
      ),
      ...primaryPages.map(
        (page) => TextButton(
          onPressed: () => _navigateTo(
            context,
            AppRoutes.pagePath(AppRoutes.slugForPageName(page.pageName)),
          ),
          style: navButtonStyle,
          child: Text(page.pageName, style: navTextStyle),
        ),
      ),
      if (dropdownPages.isNotEmpty)
        PopupMenuButton<String>(
          onSelected: (route) => _navigateTo(context, route),
          color: AppColors.primary,
          offset: const Offset(0, kToolbarHeight),
          padding: EdgeInsets.zero,
          itemBuilder: (context) {
            final genericEntries = _buildGenericPageEntries(dropdownPages);
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
          child: Padding(
            padding: _navPadding,
            child: Text('Projects', style: navTextStyle),
          ),
        ),
      const SizedBox(width: 16),
    ];
  }

  List<Widget> _buildMobileActions(BuildContext context) {
    final pages = PageCollection.instance.genericPages;
    return [
      PopupMenuButton<String>(
        onSelected: (route) {
          if (route.isEmpty) return;
          _navigateTo(context, route);
        },
        color: AppColors.primary,
        offset: const Offset(0, kToolbarHeight),
        itemBuilder: (context) {
          final items = <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: AppRoutes.landing,
              child: _menuItemText('Home'),
            ),
          ];

          final genericEntries = _buildGenericPageEntries(pages);
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

  List<PopupMenuEntry<String>> _buildGenericPageEntries(
    List<ProjectPageData> pages,
  ) {
    if (pages.isEmpty) {
      return <PopupMenuEntry<String>>[];
    }

    final normalPages = pages.where((p) => !p.allProjects).toList();
    final allProjectsPages = pages.where((p) => p.allProjects).toList();
    final orderedPages = [...normalPages, ...allProjectsPages];

    return orderedPages.map((page) {
      return PopupMenuItem<String>(
        value: AppRoutes.pagePath(AppRoutes.slugForPageName(page.pageName)),
        child: _menuItemText(page.pageName),
      );
    }).toList();
  }

  Text _menuItemText(String label) {
    return Text(label, style: const TextStyle(color: Colors.white));
  }

  void _navigateTo(BuildContext context, String route) {
    if (route.isEmpty) return;
    Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
  }
}
