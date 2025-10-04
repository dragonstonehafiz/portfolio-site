import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/theme.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  // Centralized list of social links. Each entry is a map with keys:
  // - label: String shown on the button
  // - url: destination URL
  // - asset: path to an SVG asset inside assets/svg/
  static const List<Map<String, String>> _links = [
    {
      'label': 'LinkedIn',
      'url': 'https://www.linkedin.com/in/muhdhafizabdulhalim/',
      'asset': 'assets/svg/linkedin.svg',
    },
    {
      'label': 'YouTube',
      'url': 'https://www.youtube.com/@hafiz8325',
      'asset': 'assets/svg/youtube.svg',
    },
    {
      'label': 'GitHub',
      'url': 'https://github.com/dragonstonehafiz',
      'asset': 'assets/svg/github.svg',
    },
  ];

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    // launchUrl uses the platform default (external browser on web/desktop, external app on mobile)
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // If launching fails, just print. We avoid throwing to keep UI stable.
      // In a production app you might show an error UI here.
      // ignore: avoid_print
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      color: AppColors.footerBg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Connect with me',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Render buttons from the centralized list
              for (var i = 0; i < _links.length; i++) ...[
                _buildSocialButton(
                  context,
                  _links[i]['label']!,
                  _links[i]['asset']!,
                  _links[i]['url']!,
                ),
                if (i != _links.length - 1) const SizedBox(width: 16),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '© 2025 Muhd Hafiz bin Abdul Halim. All rights reserved.',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(BuildContext context, String label, String assetPath, String url) {
    return ElevatedButton.icon(
      onPressed: () => _openLink(url),
      icon: SvgPicture.asset(
        assetPath,
        width: 20,
        height: 20,
        color: Colors.white,
      ),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.skyDark,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}