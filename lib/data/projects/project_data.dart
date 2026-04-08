

class ProjectData {
  final String variableName;
  final String title;
  final String? description;
  final String date;
  final String? lastUpdate;
  final String? vidLink;
  final String? githubLink;
  final List<String> imgPaths;
  final List<String> whatIDid;
  final List<String> tools;
  final List<String> tags;
  final String projectType;
  final String version;
  final String vignette;
  final List<String> pageList;
  // Each download entry must be a map with keys 'key' and 'url'.
  final List<ProjectDownload> downloadPaths;

  ProjectData({
    required this.variableName,
    required this.title,
    this.description,
    required this.date,
    this.lastUpdate,
    this.vidLink,
    this.githubLink,
    required this.imgPaths,
    required this.whatIDid,
    required this.tools,
    required this.tags,
    required this.projectType,
    required this.version,
    required this.vignette,
    required this.pageList,
    required this.downloadPaths,
  });

  factory ProjectData.fromJson(
    String key,
    Map<String, dynamic> json, {
    String? versionOverride,
    String? variableNameOverride,
    List<String>? pageListOverride,
  }) {
    return ProjectData(
      variableName: variableNameOverride ?? json['variable_name'] ?? key,
      title: json['title'] ?? '',
      description: json['description'],
      date: json['date'] ?? '',
      lastUpdate: json['last_update'],
      vidLink: json['vid_link'],
      githubLink: json['github_link'],
      imgPaths: List<String>.from(json['img_paths'] ?? []),
      whatIDid: List<String>.from(json['what_i_did'] ?? []),
      tools: List<String>.from(json['tools'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      projectType: json['project_type'] ?? '',
      version: versionOverride ?? json['version']?.toString() ?? 'default',
      vignette: json['vignette']?.toString() ?? '',
      pageList: pageListOverride ?? List<String>.from(json['page_list'] ?? []),
      downloadPaths: _parseDownloadPaths(
        json['download_paths'],
        projectId: key,
        versionId: versionOverride ?? json['version']?.toString() ?? 'default',
      ),
    );
  }

  static List<ProjectDownload> _parseDownloadPaths(
    dynamic raw, {
    required String projectId,
    required String versionId,
  }) {
    if (raw == null) return const [];
    if (raw is! List) {
      throw FormatException(
        'Project "$projectId" version "$versionId" has invalid "download_paths"; expected a list.',
      );
    }

    final downloads = <ProjectDownload>[];
    for (final entry in raw) {
      if (entry is! Map) {
        throw FormatException(
          'Project "$projectId" version "$versionId" has invalid download entry; expected an object with "key" and "url".',
        );
      }
      final map = Map<String, dynamic>.from(entry);
      final key = map['key'];
      final url = map['url'];
      if (key is! String || key.trim().isEmpty) {
        throw FormatException(
          'Project "$projectId" version "$versionId" has invalid download entry; "key" must be a non-empty string.',
        );
      }
      if (url is! String || url.trim().isEmpty) {
        throw FormatException(
          'Project "$projectId" version "$versionId" has invalid download entry; "url" must be a non-empty string.',
        );
      }
      downloads.add(ProjectDownload(key: key.trim(), url: url.trim()));
    }
    return downloads;
  }

  /// Return a URL-friendly slug for this project.
  String get slug {
    // Use variableName as the canonical identifier for slugs. This ensures
    // slugs are stable and unique (assuming variableName is unique in
    // projects.json).
    final base = variableName.trim().isNotEmpty ? variableName : title;
    final s = base.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), '-');
    return s.replaceAll(RegExp(r'-+'), '-').trim().replaceAll(RegExp(r'^-+|-+\$'), '');
  }

  /// Extract a YouTube video ID from common URL formats.
  /// Supports youtu.be/ID, v=ID, /embed/ID formats.
  static String? extractYoutubeId(String url) {
    try {
      final patterns = [
        RegExp(r'youtu\.be\/([\w-]{11})'),
        RegExp(r'v=([\w-]{11})'),
        RegExp(r'embed\/([\w-]{11})'),
      ];
      for (final p in patterns) {
        final m = p.firstMatch(url);
        if (m != null && m.groupCount >= 1) return m.group(1);
      }
      final any = RegExp(r'([\w-]{11})');
      final m = any.firstMatch(url);
      if (m != null) return m.group(1);
    } catch (_) {}
    return null;
  }
}

class ProjectEntry {
  final String id;
  final String defaultVersionId;
  final List<ProjectData> _versions;
  final String variableName;
  final List<String> pageList;
  final bool shown;
  final bool showInTimeline;

  ProjectEntry({
    required this.id,
    required this.defaultVersionId,
    required this.variableName,
    required this.pageList,
    required this.shown,
    required this.showInTimeline,
    required List<ProjectData> versions,
  }) : _versions = List.unmodifiable(versions);

  factory ProjectEntry.fromJson(String id, Map<String, dynamic> json) {
    final projectVariableName = json['variable_name']?.toString();
    final projectPageList = List<String>.from(json['page_list'] ?? []);
    final projectShown = json['shown'] == null ? true : json['shown'] == true;
    final showInTimeline = json['show_in_timeline'] == null ? true : json['show_in_timeline'] == true;
    final versionsRaw = json['versions'];
    if (versionsRaw is! List || versionsRaw.isEmpty) {
      throw FormatException(
        'Project "$id" is missing required non-empty "versions" array.',
      );
    }

    final versions = <ProjectData>[];
    for (final rawEntry in versionsRaw) {
      if (rawEntry is! Map) {
        throw FormatException(
          'Project "$id" has invalid version entry; expected an object.',
        );
      }
      final versionJson = Map<String, dynamic>.from(rawEntry);
      final versionId = versionJson['version']?.toString() ?? 'default';
      versions.add(
        ProjectData.fromJson(
          id,
          versionJson,
          versionOverride: versionId,
          variableNameOverride: projectVariableName,
          pageListOverride: projectPageList,
        ),
      );
    }

    final fallback = versions.first.version;
    final defaultVersion = json['default_version']?.toString();
    final resolvedDefault = defaultVersion != null &&
            versions.any((v) => v.version == defaultVersion)
        ? defaultVersion
        : fallback;

    return ProjectEntry(
      id: id,
      defaultVersionId: resolvedDefault,
      variableName: projectVariableName ?? id,
      pageList: projectPageList,
      shown: projectShown,
      showInTimeline: showInTimeline,
      versions: versions,
    );
  }

  List<ProjectData> get versions => _versions;

  int get defaultVersionIndex {
    final idx = _versions.indexWhere((v) => v.version == defaultVersionId);
    return idx == -1 ? 0 : idx;
  }

  ProjectData get defaultVersion => _versions[defaultVersionIndex];

  ProjectData? versionById(String versionId) {
    for (final version in _versions) {
      if (version.version == versionId) return version;
    }
    return null;
  }
}

class ProjectDownload {
  final String key;
  final String url;

  const ProjectDownload({required this.key, required this.url});
}
