import 'package:flutter/material.dart';

class SharedTabs extends StatelessWidget {
  final List<String> labels;
  final ValueChanged<int>? onTap;
  final bool isScrollable;
  final TabAlignment tabAlignment;

  const SharedTabs({
    super.key,
    required this.labels,
    this.onTap,
    this.isScrollable = true,
    this.tabAlignment = TabAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final primary = Theme.of(context).primaryColor;
    return TabBar(
      isScrollable: isScrollable,
      tabAlignment: tabAlignment,
      labelColor: primary,
      unselectedLabelColor: Colors.grey[600],
      indicatorColor: primary,
      labelStyle: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontSize: isMobile ? 12 : 14),
      onTap: onTap,
      tabs: labels.map((label) => Tab(text: label)).toList(),
    );
  }
}
