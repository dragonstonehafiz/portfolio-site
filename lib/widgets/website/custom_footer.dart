import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme.dart';
import '../../core/responsive_web_utils.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  // Centralized list of social links with custom button colors for each entry.
  static const List<_SocialLink> _links = [
    _SocialLink(
      label: 'LinkedIn',
      url: 'https://www.linkedin.com/in/muhdhafizabdulhalim/',
      asset: 'assets/svg/linkedin.svg',
      backgroundColor: Color(0xFF0A66C2),
    ),
    _SocialLink(
      label: 'YouTube',
      url: 'https://www.youtube.com/@hafiz8325',
      asset: 'assets/svg/youtube.svg',
      backgroundColor: Color(0xFFFF0000),
    ),
    _SocialLink(
      label: 'GitHub',
      url: 'https://github.com/dragonstonehafiz',
      asset: 'assets/svg/github.svg',
      backgroundColor: Color(0xFF333333),
    ),
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
    final isMobile = ResponsiveWebUtils.isMobile(context);
    final double spacing = isMobile ? 12.0 : 16.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 24.0,
        vertical: isMobile ? 12.0 : 24.0,
      ),
      decoration: BoxDecoration(
        gradient: Theme.of(context).primaryGradient,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: isMobile ? 160.0 : double.infinity,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Connect with me',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: spacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Render buttons from the centralized list
                for (var i = 0; i < _links.length; i++) ...[
                  _buildSocialButton(
                    context,
                    _links[i],
                  ),
                  if (i != _links.length - 1) SizedBox(width: spacing),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(BuildContext context, _SocialLink link) {
    final isMobile = ResponsiveWebUtils.isMobile(context);
    
    if (isMobile) {
      // Mobile: Show only icon button
      return ElevatedButton(
        onPressed: () => _openLink(link.url),
        style: ElevatedButton.styleFrom(
          backgroundColor: link.backgroundColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(8),
          shape: const CircleBorder(),
          minimumSize: const Size(40, 40),
        ),
        child: SvgPicture.asset(
          link.asset,
          width: 18,
          height: 18,
          color: Colors.white,
        ),
      );
    } else {
      // Desktop: Show icon + label button
      return ElevatedButton.icon(
        onPressed: () => _openLink(link.url),
        icon: SvgPicture.asset(
          link.asset,
          width: 20,
          height: 20,
          color: Colors.white,
        ),
        label: Text(link.label),
        style: ElevatedButton.styleFrom(
          backgroundColor: link.backgroundColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    }
  }
}

class _SocialLink {
  final String label;
  final String url;
  final String asset;
  final Color backgroundColor;

  const _SocialLink({
    required this.label,
    required this.url,
    required this.asset,
    required this.backgroundColor,
  });
}
