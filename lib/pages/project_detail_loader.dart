import 'package:flutter/material.dart';
import '../services/project_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_footer.dart';

class ProjectDetailLoader extends StatelessWidget {
  final String slug;
  const ProjectDetailLoader({required this.slug, super.key});

  @override
  Widget build(BuildContext context) {
    final project = ProjectService.getProjectBySlug(slug);
    
    if (project == null) {
      return Scaffold(
        appBar: const CustomAppBar(),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Project not found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('The requested project could not be found.'),
                  ],
                ),
              ),
            ),
            const CustomFooter(),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Expanded(child: project.buildFullWidget(context)),
          const CustomFooter(),
        ],
      ),
    );
  }
}
