import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/responsive_web_utils.dart';
import '../../data/landing/landing_page_data.dart';
import '../../data/projects/project_data.dart';
import '../../data/projects/project_collection.dart';
import '../ui/animated_gradient.dart';
import '../generic/project_horizontal_carousel.dart';
import '../generic/shared_tabs.dart';
import '../generic/tool_badge_list.dart';
import '../generic/tool_badge_compact.dart';

/// Landing page skills section with tabs for different skill categories
class LandingSkillsSection extends StatefulWidget {
  final Skills skills;

  const LandingSkillsSection({super.key, required this.skills});

  @override
  State<LandingSkillsSection> createState() => _LandingSkillsSectionState();
}

class _LandingSkillsSectionState extends State<LandingSkillsSection> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWebUtils.isMobile(context);
    final categories = widget.skills.categories.entries
        .where((e) => e.value.items.isNotEmpty)
        .toList();

    if (categories.isEmpty) return const SizedBox.shrink();
    if (_tabIndex >= categories.length) {
      _tabIndex = 0;
    }
    final currentEntry = categories[_tabIndex];

    return DefaultTabController(
      length: categories.length,
      child: _buildSkillCategoryCard(
        categories: categories,
        currentEntry: currentEntry,
        isMobile: isMobile,
      ),
    );
  }

  Widget _buildSkillCategoryCard({
    required List<MapEntry<String, SkillCategory>> categories,
    required MapEntry<String, SkillCategory> currentEntry,
    required bool isMobile,
  }) {
    final desc = currentEntry.value.description;
    final relatedProjects = _resolveRelatedProjects(
      currentEntry.value.relatedProjects,
    );
    final carouselHeight = isMobile ? 235.0 : 255.0;
    final carouselCardWidth = isMobile ? 280.0 : 340.0;
    final filteredItems = currentEntry.value.items;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedGradient(
        gradient: Theme.of(context).previewGradient,
        borderRadius: BorderRadius.circular(12),
        duration: const Duration(seconds: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SelectionArea(
            child: DefaultTextStyle(
              style: const TextStyle(color: Color(0xFF0F1724)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SharedTabs(
                    labels: categories.map((e) => e.key).toList(),
                    onTap: (index) => setState(() => _tabIndex = index),
                  ),
                  const SizedBox(height: 12),
                  if (desc.trim().isNotEmpty) ...[
                    Text(
                      desc,
                      style:
                          Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(height: 1.4) ??
                          const TextStyle(
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (isMobile)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: filteredItems
                          .map(
                            (tool) => ToolBadgeCompact(
                              toolKey: tool,
                              fontSize: 11,
                            ),
                          )
                          .toList(),
                    )
                  else
                    ToolBadgeList(
                      tools: filteredItems,
                      showIcons: true,
                      fontSize: 13,
                      spacing: 8,
                      runSpacing: 8,
                    ),
                  if (relatedProjects.isNotEmpty &&
                      filteredItems.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: carouselHeight,
                      child: SelectionContainer.disabled(
                        child: ProjectHorizontalCarousel(
                          projects: relatedProjects,
                          cardWidth: carouselCardWidth,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<ProjectData> _resolveRelatedProjects(List<String> ids) {
    if (ids.isEmpty) return [];

    final collection = ProjectsCollection.instance.projects;
    final projects = <ProjectData>[];
    for (final id in ids) {
      final entry = collection[id];
      if (entry != null) {
        projects.add(entry.defaultVersion);
        continue;
      }
      // Fallback: match by variableName or slug.
      for (final p in collection.values) {
        final def = p.defaultVersion;
        if (p.variableName == id || def.slug == id) {
          projects.add(def);
          break;
        }
      }
    }
    return projects;
  }
}
