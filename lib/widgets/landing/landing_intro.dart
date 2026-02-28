import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/landing/landing_page_data.dart';

/// Landing page introduction widget displaying name, headline, summary, and download buttons
class LandingIntro extends StatelessWidget {
  final Intro intro;

  const LandingIntro({super.key, required this.intro});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            intro.name,
            style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(intro.headline, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(
            intro.summary,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: intro.downloads.map((d) {
              return ElevatedButton(
                onPressed: () => _openUrl(d.url, external: d.external),
                child: Text(d.label),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _openUrl(String url, {bool external = false}) async {
    final uri = Uri.parse(url);
    if (external) {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri);
      }
    } else {
      // attempt to open local asset or fallback to external
      if (!await launchUrl(uri)) {
        // ignore
      }
    }
  }
}
