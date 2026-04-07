import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/ui/custom_app_bar.dart';
import '../widgets/ui/custom_footer.dart';
import '../core/responsive_web_utils.dart';

class NotFoundPage extends StatelessWidget {
  final String requestedPath;

  const NotFoundPage({super.key, required this.requestedPath});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: ResponsiveWebUtils.getResponsivePadding(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '404',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Page not found.',
                      style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Requested path: $requestedPath',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const CustomFooter(),
        ],
      ),
    );
  }
}
