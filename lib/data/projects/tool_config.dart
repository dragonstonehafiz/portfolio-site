import 'package:flutter/material.dart';

/// Configuration for technology/tool badges with colors and icon data
class ToolConfig {
  final String displayName;
  final Color backgroundColor;
  final Color textColor;
  final String? iconUrl; // URL to icon (e.g., from Simple Icons CDN)

  const ToolConfig({
    required this.displayName,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.iconUrl,
  });
}

/// Map of tool identifiers to their visual configuration
/// Icons are loaded from jsDelivr CDN: https://www.jsdelivr.com/package/npm/simple-icons
const Map<String, ToolConfig> toolConfigs = {
  // Programming Languages
  'python': ToolConfig(
    displayName: 'Python',
    backgroundColor: Color(0xFF3776AB),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/python.svg',
  ),
  'c++': ToolConfig(
    displayName: 'C++',
    backgroundColor: Color(0xFF00599C),
    iconUrl:
        'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/cplusplus.svg',
  ),
  'c#': ToolConfig(
    displayName: 'C#',
    backgroundColor: Color(0xFF239120),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/csharp.svg',
  ),
  'java': ToolConfig(
    displayName: 'Java',
    backgroundColor: Color(0xFF007396),
    iconUrl:
        'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/java/java-original.svg',
  ),
  'typescript': ToolConfig(
    displayName: 'TypeScript',
    backgroundColor: Color(0xFF3178C6),
    iconUrl:
        'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/typescript.svg',
  ),
  'javascript': ToolConfig(
    displayName: 'JavaScript',
    backgroundColor: Color(0xFFF7DF1E),
    textColor: Color(0xFF000000),
    iconUrl:
        'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/javascript.svg',
  ),
  'dart': ToolConfig(
    displayName: 'Dart',
    backgroundColor: Color(0xFF0175C2),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/dart.svg',
  ),
  'r': ToolConfig(
    displayName: 'R',
    backgroundColor: Color(0xFF276DC3),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/r.svg',
  ),
  'c': ToolConfig(
    displayName: 'C',
    backgroundColor: Color(0xFFA8B9CC),
    textColor: Color(0xFF000000),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/c.svg',
  ),

  // Frameworks & Libraries
  'flutter': ToolConfig(
    displayName: 'Flutter',
    backgroundColor: Color(0xFF02569B),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/flutter.svg',
  ),
  'angular': ToolConfig(
    displayName: 'Angular',
    backgroundColor: Color(0xFFDD0031),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/angular.svg',
  ),
  'react': ToolConfig(
    displayName: 'React',
    backgroundColor: Color(0xFF61DAFB),
    textColor: Color(0xFF000000),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/react.svg',
  ),
  'vue.js': ToolConfig(
    displayName: 'Vue.js',
    backgroundColor: Color(0xFF4FC08D),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/vuedotjs.svg',
  ),
  'fastapi': ToolConfig(
    displayName: 'FastAPI',
    backgroundColor: Color(0xFF009688),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/fastapi.svg',
  ),
  'node.js': ToolConfig(
    displayName: 'Node.js',
    backgroundColor: Color(0xFF339933),
    iconUrl:
        'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/nodedotjs.svg',
  ),
  'libgdx': ToolConfig(
    displayName: 'LibGDX',
    backgroundColor: Color(0xFFE64A19),
    iconUrl: 'assets/svg/libgdx.svg',
  ),

  // Game Engines
  'unity': ToolConfig(
    displayName: 'Unity',
    backgroundColor: Color(0xFF000000),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/unity.svg',
  ),
  'unreal': ToolConfig(
    displayName: 'Unreal',
    backgroundColor: Color(0xFF0E1128),
    iconUrl:
        'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/unrealengine.svg',
  ),

  // Tools & Platforms
  'docker': ToolConfig(
    displayName: 'Docker',
    backgroundColor: Color(0xFF2496ED),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/docker.svg',
  ),
  'git': ToolConfig(
    displayName: 'Git',
    backgroundColor: Color(0xFFF05032),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/git.svg',
  ),
  'excel': ToolConfig(
    displayName: 'Excel',
    backgroundColor: Color(0xFF217346),
    iconUrl:
        'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/microsoftexcel.svg',
  ),
  'google cloud': ToolConfig(
    displayName: 'Google Cloud',
    backgroundColor: Color(0xFF4285F4),
    iconUrl:
        'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/googlecloud.svg',
  ),
  'aws': ToolConfig(
    displayName: 'AWS',
    backgroundColor: Color(0xFFFF9900),
    textColor: Color(0xFF000000),
    iconUrl:
        'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/amazonaws.svg',
  ),
  'firebase': ToolConfig(
    displayName: 'Firebase',
    backgroundColor: Color(0xFFFFCA28),
    textColor: Color(0xFF000000),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/firebase.svg',
  ),

  // Concepts/Categories (use generic icons or placeholders)
  'ai': ToolConfig(
    displayName: 'AI',
    backgroundColor: Color(0xFF8E24AA),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/openai.svg',
  ),
  'machine learning': ToolConfig(
    displayName: 'Machine Learning',
    backgroundColor: Color(0xFF5E35B1),
    iconUrl:
        'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/tensorflow.svg',
  ),
  'computer vision': ToolConfig(
    displayName: 'Computer Vision',
    backgroundColor: Color(0xFF6A1B9A),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/opencv.svg',
  ),
  'rest api': ToolConfig(
    displayName: 'REST API',
    backgroundColor: Color(0xFF00796B),
    iconUrl: null, // REST API is a concept, not a specific tool with a logo
  ),
  'mqtt': ToolConfig(
    displayName: 'MQTT',
    backgroundColor: Color(0xFF660099),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/mqtt.svg',
  ),
  'html/css': ToolConfig(
    displayName: 'HTML/CSS',
    backgroundColor: Color(0xFFE34F26),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/html5.svg',
  ),

  // Development Tools
  'visual studio code': ToolConfig(
    displayName: 'Visual Studio Code',
    backgroundColor: Color(0xFF007ACC),
    iconUrl:
        'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/visualstudiocode.svg',
  ),
  'visual studio': ToolConfig(
    displayName: 'Visual Studio',
    backgroundColor: Color(0xFF5C2D91),
    iconUrl:
        'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/visualstudio.svg',
  ),
  'intellij idea': ToolConfig(
    displayName: 'IntelliJ IDEA',
    backgroundColor: Color(0xFF000000),
    iconUrl:
        'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/intellijidea.svg',
  ),
  'android studio': ToolConfig(
    displayName: 'Android Studio',
    backgroundColor: Color(0xFF3DDC84),
    textColor: Color(0xFF000000),
    iconUrl:
        'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/androidstudio.svg',
  ),
  'sourcetree': ToolConfig(
    displayName: 'SourceTree',
    backgroundColor: Color(0xFF0052CC),
    iconUrl:
        'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/sourcetree.svg',
  ),

  // Creative Tools
  'adobe premiere pro': ToolConfig(
    displayName: 'Adobe Premiere Pro',
    backgroundColor: Color(0xFF9999FF),
    textColor: Color(0xFF000000),
    iconUrl:
        'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/adobepremierepro.svg',
  ),
  'adobe photoshop': ToolConfig(
    displayName: 'Adobe Photoshop',
    backgroundColor: Color(0xFF31A8FF),
    iconUrl:
        'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/adobephotoshop.svg',
  ),
  'adobe audition': ToolConfig(
    displayName: 'Adobe Audition',
    backgroundColor: Color(0xFF9999FF),
    textColor: Color(0xFF000000),
    iconUrl:
        'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/adobeaudition.svg',
  ),
  'davinci resolve': ToolConfig(
    displayName: 'DaVinci Resolve',
    backgroundColor: Color(0xFF233A51),
    iconUrl:
        'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/davinciresolve.svg',
  ),
  'affinity photo 2': ToolConfig(
    displayName: 'Affinity Photo 2',
    backgroundColor: Color(0xFF7E4DD2),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/affinity.svg',
  ),

  // AI/ML Concepts
  'deep learning': ToolConfig(
    displayName: 'Deep Learning',
    backgroundColor: Color(0xFF673AB7),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/keras.svg',
  ),
  'llms': ToolConfig(
    displayName: 'LLMs',
    backgroundColor: Color(0xFF412991),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/openai.svg',
  ),
  'inference pipelines': ToolConfig(
    displayName: 'Inference Pipelines',
    backgroundColor: Color(0xFF4A148C),
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/pytorch.svg',
  ),
};

/// Get tool configuration, returns default if not found
ToolConfig getToolConfig(String toolKey) {
  final key = toolKey.toLowerCase().trim();
  return toolConfigs[key] ??
      ToolConfig(
        displayName: toolKey, // Show unknown tools as-is
        backgroundColor: const Color(0xFF607D8B), // Default grey
        iconUrl: null, // No icon for unknown tools
      );
}

/// Extract all unique tools from projects data
Set<String> extractUniqueTools(Map<String, dynamic> projectsJson) {
  final Set<String> tools = {};

  for (var projectEntry in projectsJson.values) {
    if (projectEntry is Map<String, dynamic>) {
      final versions = projectEntry['versions'];
      if (versions is List) {
        for (var version in versions) {
          if (version is Map<String, dynamic>) {
            final versionTools = version['tools'];
            if (versionTools is List) {
              tools.addAll(versionTools.map((t) => t.toString().toLowerCase()));
            }
          }
        }
      }
    }
  }

  return tools;
}
