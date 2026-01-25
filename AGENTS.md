# AGENTS.md - Portfolio Site

## Purpose
- This repo is a Flutter Web portfolio site driven by JSON assets.
- This file summarizes the data sources, routing, widgets, and pages needed to maintain the site.

## Entry and Initialization
- Entry point: lib/main.dart
- Startup sequence:
  - WidgetsFlutterBinding.ensureInitialized()
  - usePathUrlStrategy() for clean URLs
  - ProjectsCollection.initializeFromAssets() loads assets/projects.json
  - AppRoutes.initialize() loads PageCollection from assets/page_config.json and builds slug map
  - runApp(PortfolioApp)

## Routing
- Routing is handled in lib/main.dart via onGenerateRoute
- Static routes:
  - / -> LandingPage
- Dynamic routes:
  - /pages/<slug> -> ProjectsBasePage for a page name resolved from AppRoutes.genericPageSlugs
  - /projects/<slug> -> ProjectDetailLoader
- Slug rules:
  - Page slug: AppRoutes.slugForPageName(page_name) from assets/page_config.json
  - Project slug: ProjectData.slug uses variable_name (fallback to title) from assets/projects.json

## Data Sources (JSON)
- assets/page_config.json
  - project_pages: [ { page_name, description, default_list_view, dropdown } ]
  - Consumed by PageCollection (lib/utils/page_collection.dart)
  - Used by AppRoutes.initialize() and ProjectsBasePage
- assets/projects.json
  - Top-level map of projectId -> { variable_name, page_list, shown, default_version, versions[] }
  - show_in_timeline: optional flag to include/exclude a project from the Timeline widget (default true)
  - Each version includes:
    - version, title, vignette, description, date, last_update
    - vid_link, github_link, img_paths[], what_i_did[], tags[], project_type, download_paths[]
  - Loaded by ProjectsCollection (lib/utils/project_collection.dart)
  - Rendered by ProjectData widgets (lib/utils/project_data.dart)
- assets/landing_page.json
  - introduction: { name, headline, summary, downloads[] }
  - experience: [ { start, end, title, company, bullets[] } ]
  - education: [ { school, course, start, end, modules[] } ]
  - skills: dynamic map of category -> [ items ]
  - Loaded by LandingPageData (lib/utils/landing_page_data.dart)

## Core Pages
- lib/pages/landing_page.dart
  - Loads LandingPageData from assets/landing_page.json
  - Sections: Intro, Experience, Education (tabbed modules), Skills
  - Uses AnimatedGradient cards and CustomAppBar/CustomFooter
- lib/pages/projects_base_page.dart
  - Generic listing page for featured or any page in page_config.json
  - Filters: tag, project type; search query; sort by date; list/grid view
  - Renders ProjectData previews or list items
- lib/pages/project_detail_loader.dart
  - Resolves project entry by slug via ProjectService
  - Handles multi-version projects with TabBar
  - Renders ProjectData.buildDetailBody

## Widgets
- lib/widgets/custom_app_bar.dart
  - Desktop: Home + non-dropdown pages as buttons; dropdown pages grouped into a menu
  - Mobile: Popup menu
  - Uses AppRoutes.genericPageSlugs
- lib/widgets/custom_footer.dart
  - Social links (LinkedIn, YouTube, GitHub) with SVG icons
- lib/widgets/hover_card_widget.dart
  - Web hover scale + elevation
- lib/widgets/search_bar_widget.dart
  - Simple text field used by ProjectsBasePage
- lib/widgets/animated_gradient.dart
  - Subtle animated gradient background container
- lib/widgets/youtube_embedded.dart
  - Embedded YouTube iframe on web, external link fallback elsewhere
- lib/widgets/web_iframe_helper_html.dart
  - Iframe creation and pointer-event gating for web

## Services and Utilities
- lib/services/project_service.dart
  - Reads PageCollection + ProjectsCollection
  - getProjectsForPage() sorts by last_update/date
  - Tag filtering, search, project type lists
  - getProjectEntryBySlug() maps slug to a ProjectEntry
- lib/utils/project_data.dart
  - Defines ProjectData, ProjectEntry, and all project rendering widgets
  - Preview cards, list items, gallery, details, downloads
- lib/utils/page_collection.dart
  - Singleton loader for page_config.json
- lib/utils/landing_page_data.dart
  - Loader + models for landing_page.json
- lib/utils/responsive_web_utils.dart
  - Mobile breakpoint and responsive padding helpers
- lib/utils/theme.dart
  - App colors, gradients, text theme, GradientScaffold wrapper

## Assets
- Images: assets/images/games/, assets/images/other/, assets/images/sit/
  - Referenced by img_paths in assets/projects.json
- SVG icons: assets/svg/ (used by CustomFooter)
- Included in pubspec.yaml under flutter/assets

## How to Add or Edit Content
- Add a new project:
  1) Add entry in assets/projects.json with unique projectId and versions.
  2) Ensure variable_name is stable (used in slugs).
  3) Set page_list to the pages this project should appear on.
  4) Set shown to control whether the project appears in listings.
  5) Add images under assets/images/... and reference paths without the assets/ prefix.
- Add a new page:
  1) Add a new object in page_config.json project_pages with page_name, description, and dropdown flag.
  2) AppRoutes.initialize() will slugify page_name for /pages/<slug> routing.
  3) CustomAppBar will auto-pick it up in navigation.
  4) Update each project’s page_list to include the new page_name as needed.
- Edit landing content:
  - Update assets/landing_page.json; LandingPage reads and renders dynamically.

## Notes
- All content is data-driven from JSON in assets/.
- For project detail routing, ensure project variable_name is unique so slugs do not collide.
- For the Featured page, include 'Featured' in a project’s page_list.
- In assets/projects.json, keep page_list and tags arrays on a single line for readability.
