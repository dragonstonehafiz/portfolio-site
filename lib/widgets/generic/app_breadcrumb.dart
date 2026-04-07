import 'package:flutter/material.dart';

import '../../core/theme.dart';

class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  const BreadcrumbItem({required this.label, this.onTap});
}

class AppBreadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const AppBreadcrumb({required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final isMobile = MediaQuery.of(context).size.width < 768;
    final separatorStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: isMobile ? 11 : 14,
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _BreadcrumbLabel(item: items[i], isMobile: isMobile),
          if (i != items.length - 1)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '/',
                style: separatorStyle,
              ),
            ),
        ],
      ],
    );
  }
}

class _BreadcrumbLabel extends StatelessWidget {
  final BreadcrumbItem item;
  final bool isMobile;

  const _BreadcrumbLabel({required this.item, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (item.onTap != null) {
      return TextButton(
        onPressed: item.onTap,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(item.label, style: TextStyle(fontSize: isMobile ? 11 : 14)),
      );
    }

    return Text(
      item.label,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontSize: isMobile ? 11 : 14,
      ),
    );
  }
}
