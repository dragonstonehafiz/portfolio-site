import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../core/responsive_web_utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    this.automaticallyImplyLeading = true,
  });

  static const EdgeInsets _navPadding = EdgeInsets.symmetric(horizontal: 10.0);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWebUtils.isMobile(context);

    return Container(
      decoration: BoxDecoration(gradient: Theme.of(context).primaryGradient),
      child: AppBar(
        automaticallyImplyLeading: automaticallyImplyLeading,
        titleSpacing: 16,
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
      TextButton(
        onPressed: () => _navigateTo(context, AppRoutes.projectSummaryPath),
        style: navButtonStyle,
        child: Text('Projects', style: navTextStyle),
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
        color: AppColors.primary,
        offset: const Offset(0, kToolbarHeight),
        itemBuilder: (context) {
          final items = <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: AppRoutes.landing,
              child: _menuItemText('Home'),
            ),
            PopupMenuItem<String>(
              value: AppRoutes.projectSummaryPath,
              child: _menuItemText('Projects'),
            ),
          ];
          return items;
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            'Pages',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      const SizedBox(width: 8),
    ];
  }

  Text _menuItemText(String label) {
    return Text(label, style: const TextStyle(color: Colors.white));
  }

  void _navigateTo(BuildContext context, String route) {
    if (route.isEmpty) return;
    Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
  }
}
