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

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _BreadcrumbLabel(item: items[i]),
          if (i != items.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '/',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
        ],
      ],
    );
  }
}

class _BreadcrumbLabel extends StatelessWidget {
  final BreadcrumbItem item;

  const _BreadcrumbLabel({required this.item});

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
        child: Text(item.label),
      );
    }

    return Text(
      item.label,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}
