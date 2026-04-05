# AGENTS.MD

This document reflects how the codebase currently works. Use it as the source of truth before making redesign changes.

## Stack

| Layer | Technology |
|---|---|
| Language | Dart 3.9+ |
| Framework | Flutter (web target) |
| UI | Material 3 (`useMaterial3: true`) |
| Fonts | Google Fonts `Inter` |
| Routing | `MaterialApp.onGenerateRoute` + path URL strategy |
| Assets/Data | JSON files in `assets/` |

## Startup and Routing

Startup flow in `lib/main.dart`:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `usePathUrlStrategy()`
3. `await Future.wait([ProjectsCollection.initializeFromAssets(), AppRoutes.initialize()])`
4. `runApp(const PortfolioApp())`

`AppRoutes.initialize()` in `lib/core/routes.dart` loads `PageCollection` and builds `genericPageSlugs` (`slug -> page_name`).

Routing is handled in `MaterialApp.onGenerateRoute`:

- `/` -> `LandingPage`
- `/pages/<slug>` -> resolves slug from `AppRoutes.genericPageSlugs`, then builds `ProjectsBasePage`
- `/projects/<slug>` -> `ProjectDetailPage(slug: slug)`

Navigation UI is dynamic from `PageCollection` in `lib/widgets/ui/custom_app_bar.dart`.

## Data Layer

### Projects

- Source: `assets/projects.json`
- Loader: `ProjectsCollection.initializeFromAssets()`
- Singleton: `ProjectsCollection.instance`
- Models: `ProjectEntry` and `ProjectData` in `lib/data/projects/project_data.dart`

Important behavior:

- `ProjectEntry` supports multiple versions and a `default_version`
- Slug comes from `ProjectData.slug`, which is based on `variable_name` (fallback `title`)
- `shown` and `show_in_timeline` flags are enforced in UI/data assembly

### Pages

- Source: `assets/page_config.json`
- Loader: `PageCollection.initializeFromAssets()`
- Singleton: `PageCollection.instance`
- Model: `ProjectPageData` (`page_name`, `description`, `default_list_view`, `dropdown`, `all_projects`)

### Landing

- Source: `assets/landing_page.json`
- Loader: `LandingPageData.loadFromAssets()` (currently called from `LandingPage.initState`)
- Model: `lib/data/landing/landing_page_data.dart`

Current landing JSON keys expected by code:

- `introduction`: `name`, `headline`, `summary`, `downloads[{label,url,external}]`
- `experience[]`: `start`, `end`, `title`, `company`, `icon`, `bullets[]`
- `education[]`: `start`, `end`, `school`, `course`, `final_gpa`, `icon`, `modules[{name,items[]}]`
- `skills`: map of category -> `{description, related_projects[], items[]}`

## Service Layer

Primary project read API is `ProjectService` (`lib/data/projects/project_service.dart`):

- `getProjectsForPage(pageName, descending: true)`
- `getProjectEntryBySlug(slug)`
- `getProjectBySlug(slug)`
- `searchProjects(query)`
- `getAllTags()`, `getAllTools()`

Filtering on tags/type/tools/search for `ProjectsBasePage` is currently done in-page after fetching page projects.

## UI Architecture

Core pages:

- `lib/pages/landing_page.dart`
- `lib/pages/projects_base_page.dart`
- `lib/pages/project_detail_page.dart`

Shared shells/components:

- `lib/widgets/ui/custom_app_bar.dart`
- `lib/widgets/ui/custom_footer.dart`
- `lib/core/theme.dart` (`AppColors`, gradients, `GradientScaffold`)
- `lib/core/responsive_web_utils.dart` (`mobileBreakpoint = 768`, responsive padding helpers; currently moderate global horizontal gutters)

Project widgets:

- Grid card: `project_preview_card.dart`
- List row: `project_list_item.dart`
- Compact card: `project_compact_card.dart`
- Detail body: `project_full_detail_card.dart`
- Media: `project_thumbnail_preview.dart`, `image_gallery.dart`, `youtube_video_player.dart`

Landing widgets:

- Intro, work, education, skills sections under `lib/widgets/landing/`
- Timeline assembly in `TimelineData.fromLandingPageData(...)`
- Active timeline widget: `TimelineSingleYear`

## Shared Widget Catalog (What Exists, How It Is Used)

This section is the practical map for redesign work. Prefer styling/composition changes inside these widgets instead of replacing page flows.

### UI Shell Widgets (`lib/widgets/ui/`)

- `CustomAppBar`
  - Used by: Landing, Projects list page, Project detail page.
  - Responsibility: Dynamic nav from `PageCollection`; desktop primary links + Projects dropdown; mobile popup menu.
  - Contract: Route generation must keep using `AppRoutes.pagePath(AppRoutes.slugForPageName(...))`.

- `CustomFooter`
  - Used by: Landing, Projects list page, Project detail page.
  - Responsibility: Shared social CTA and external links (LinkedIn, YouTube, GitHub).
  - Contract: Keep footer globally reusable and safe for both mobile and desktop.

- `AnimatedGradient`
  - Used by: Project cards/list items, timeline containers, work/education/skills cards.
  - Responsibility: Reusable animated gradient background wrapper.
  - Contract: Visual only; should not contain business logic.
  - Current behavior: hard-edged container (`BorderRadius.zero`) with a subtle 1px border.

- `HoverCardWidget`
  - Used by: `ProjectPreviewCard`, `ProjectListItem`, `ProjectCompactCard`.
  - Responsibility: Shared hover lift/scale + material ink behavior for clickable cards on web.
  - Contract: Preserve clickability and hover affordance.

- `GradientScaffold` (`lib/core/theme.dart`)
  - Used by: All 3 top-level pages.
  - Responsibility: Shared page shell with scaffold gradient and transparent scaffold background.
  - Contract: Keep page-level gradient behavior centralized.

### Generic Reusable Widgets (`lib/widgets/generic/`)

- `SearchBarWidget`
  - Used by: `ProjectsBasePage`.
  - Responsibility: Shared project search input control.

- `SharedTabs`
  - Used by: Project detail version tabs, education module tabs, skills category tabs.
  - Responsibility: Consistent tab styling + responsive label sizing.

- `ToolBadge` / `ToolBadgeList` / `ToolBadgeCompact` / `ToolBadgeLarge`
  - Used by: Project preview/list/detail, skills section.
  - Responsibility: Standardized tool chips via `tool_config.dart` mapping.
  - Contract: Tool colors/icons come from `lib/data/projects/tool_config.dart`, not per-widget hardcoding.

- `ImageGallery`
  - Used by: `ProjectFullDetailCard`.
  - Responsibility: Auto-advancing image carousel with thumbnails + full image dialog.

- `YoutubeVideoPlayer`
  - Used by: `ProjectFullDetailCard`.
  - Responsibility: Responsive video embed (iframe on web) with external-link fallback.

- `ProjectHorizontalCarousel`
  - Used by: `LandingSkillsSection` (and intended for reuse in any page).
  - Responsibility: Reusable horizontal carousel for `ProjectCompactCard` items.
  - Contract: Sizing is controlled by explicit `cardWidth` (+ height constraints), not items-per-viewport.
  - Interaction: Supports drag/trackpad + mouse wheel horizontal scrolling.

### Project Domain Widgets (`lib/widgets/project/`)

- `ProjectPreviewCard`
  - Used by: Projects grid views.
  - Responsibility: Primary card view for project summaries; navigates to `/projects/<slug>`.

- `ProjectListItem`
  - Used by: Projects list view mode.
  - Responsibility: Dense row-style project summary with links, tags, tools, and date/download indicators.

- `ProjectCompactCard`
  - Used by: `ProjectHorizontalCarousel`.
  - Responsibility: Small clickable project tile with top media, type badge, and compact meta rows.
  - Notes: title/tools rows support automatic horizontal ticker behavior when content overflows; media area consumes remaining height after title/tools block.

- `ProjectFullDetailCard`
  - Used by: Project detail page.
  - Responsibility: Full project content sections (meta, gallery, details, tools, tags, downloads), including internal section switchers.

- `ProjectThumbnailPreview`
  - Used by: Project preview/list, timeline tooltips.
  - Responsibility: Shared thumbnail renderer for image-first, YouTube thumbnail fallback, or placeholder.

### Landing Domain Widgets (`lib/widgets/landing/`)

- `LandingIntro`
  - Responsibility: Name/headline/summary/download actions.

- `LandingWorkCard`
  - Responsibility: Work experience card rendering.

- `LandingEducationCard`
  - Responsibility: Education card + module groups via `SharedTabs`.

- `LandingSkillsSection`
  - Responsibility: Skills category tabs, skill badges, related projects integration.
  - Notes: tabs render inside the skills card; related projects render via `ProjectHorizontalCarousel`.

- `TimelineSingleYear`
  - Used by: landing page today.
  - Responsibility: Interactive year-based timeline with project dots + work/education ranges + legend filters.

- `TimelineMultiYear`
  - Present but not currently mounted in landing page.
  - Responsibility: Horizontal multi-year timeline variant.

- `RangeTooltipWidget`, `ProjectTooltipWidget`, `HoverTooltipWidget` (`timeline_tooltips.dart`)
  - Responsibility: Shared hover tooltip system for timeline ranges and project nodes.

### Usage Map (Current)

- Landing page (`landing_page.dart`)
  - `GradientScaffold` + `CustomAppBar` + `CustomFooter`
  - `LandingIntro`, `TimelineSingleYear`, `LandingWorkCard`, `LandingEducationCard`, `LandingSkillsSection`

- Projects base page (`projects_base_page.dart`)
  - `GradientScaffold` + `CustomAppBar` + `CustomFooter`
  - `SearchBarWidget`, `ProjectPreviewCard`, `ProjectListItem`

- Project detail page (`project_detail_page.dart`)
  - `GradientScaffold` + `CustomAppBar` + `CustomFooter`
  - `SharedTabs` (version tabs), `ProjectFullDetailCard`

### Redesign Boundaries for Shared Widgets

1. Safe changes: spacing, typography, color tokens, hover/transition polish, layout composition.
2. Risky changes: route behavior, slug generation, data loading lifecycle, JSON key contracts.
3. If redesigning a page, first prefer editing leaf widgets (`project_*`, `landing_*`) before changing page-level control flow.

## Complete Widget Inventory (Current Files)

This is the full widget file map under `lib/widgets/`.

### `lib/widgets/ui`

- `custom_app_bar.dart`: dynamic top navigation from `PageCollection`.
- `custom_footer.dart`: global footer with social links.
- `animated_gradient.dart`: animated gradient wrapper container.
- `hover_card.dart`: hover scale/elevation wrapper for clickable cards.

### `lib/widgets/generic`

- `search_bar.dart`: reusable search text field widget.
- `shared_tabs.dart`: common `TabBar` styling wrapper.
- `tool_badge_base.dart`: core tool badge renderer + safe SVG/network icon loader.
- `tool_badge_list.dart`: wrap list of tool badges.
- `tool_badge_compact.dart`: compact badge variant.
- `tool_badge_large.dart`: large badge variant.
- `project_horizontal_carousel.dart`: reusable horizontal carousel for project compact cards.
- `image_gallery.dart`: image carousel with auto-advance + thumbnail strip + fullscreen dialog.
- `youtube_video_player.dart`: responsive YouTube embed/fallback button.

### `lib/widgets/project`

- `project_preview_card.dart`: grid-style project card, links to project detail route.
- `project_list_item.dart`: list-style project row, links to project detail route.
- `project_compact_card.dart`: compact clickable project tile used in landing skills carousel.
- `project_full_detail_card.dart`: full detail content renderer including gallery/details switchers.
- `project_thumbnail_preview.dart`: thumbnail renderer for image/video placeholder.

### `lib/widgets/landing`

- `landing_intro.dart`: intro block.
- `landing_work_card.dart`: experience card.
- `landing_education_card.dart`: education card with modules tabbing.
- `landing_skills_section.dart`: skills tabbed section + related project mapping.
- `timeline_single_year.dart`: active timeline implementation currently mounted on landing page.
- `timeline_multi_year.dart`: alternate timeline implementation (present, not currently mounted).
- `timeline_tooltips.dart`: hover tooltip overlay system + tooltip widgets.

## Full Page Wiring (Widget Composition)

- Landing page (`lib/pages/landing_page.dart`)
  - Shell: `GradientScaffold` -> `CustomAppBar` + `CustomFooter`
  - Body sections: `LandingIntro` -> `TimelineSingleYear` -> `LandingWorkCard*` -> `LandingEducationCard*` -> `LandingSkillsSection`

- Projects page (`lib/pages/projects_base_page.dart`)
  - Shell: `GradientScaffold` -> `CustomAppBar` + `CustomFooter`
  - Controls: header filter dropdowns + `SearchBarWidget` + sort + list/grid toggle
  - Content: `ProjectPreviewCard*` (grid) or `ProjectListItem*` (list)

- Project detail (`lib/pages/project_detail_page.dart`)
  - Shell: `GradientScaffold` -> `CustomAppBar` + `CustomFooter`
  - Body: `SharedTabs` for versions -> `ProjectFullDetailCard`
  - Inside detail: `YoutubeVideoPlayer`, `ImageGallery`, `ToolBadgeList`, tag chips, download buttons

## Exact Data Contracts in Code (Not Aspirational)

### `assets/projects.json` example (parsed by `ProjectEntry.fromJson` / `ProjectData.fromJson`)

```json
{
  "AiGameProject": {
    "variable_name": "ai-game-project",
    "page_list": ["Featured", "All Projects"],
    "shown": true,
    "show_in_timeline": true,
    "default_version": "Submission",
    "versions": [
      {
        "version": "Submission",
        "title": "AI Game Project",
        "description": "Built an AI-powered gameplay prototype.",
        "date": "2024-10-01",
        "last_update": "2025-01-15",
        "vignette": "Prototype game using AI behaviors.",
        "project_type": "Games",
        "tags": ["ai", "games"],
        "tools": ["c++", "unreal"],
        "img_paths": ["images/games/aigame1.png", "images/games/aigame2.png"],
        "vid_link": "https://youtu.be/abcdefghijk",
        "github_link": "https://github.com/example/ai-game-project",
        "download_paths": [
          { "key": "Build", "url": "https://example.com/download/build.zip" }
        ],
        "what_i_did": [
          "Implemented enemy behavior trees.",
          "Integrated AI-assisted content pipeline."
        ]
      }
    ]
  }
}
```

Notes:
- Top-level key is project id (`AiGameProject` above).
- Slug is derived from `variable_name`; do not rename it once links are live.
- If `versions` is missing, parser falls back to single-version mode.

### `assets/page_config.json` example (parsed by `ProjectPageData.fromJson`)

```json
{
  "project_pages": [
    {
      "page_name": "Featured",
      "description": "Highlights from recent work ({count} projects).",
      "default_list_view": false,
      "dropdown": false,
      "all_projects": false
    },
    {
      "page_name": "All Projects",
      "description": "Everything I've built ({count} projects).",
      "default_list_view": true,
      "dropdown": true,
      "all_projects": true
    }
  ]
}
```

Notes:
- `dropdown: true` controls inclusion under the Projects menu in nav.
- `all_projects: true` ignores `page_list` filtering and includes all shown projects.

### `assets/landing_page.json` example (parsed by `LandingPageData.fromJson`)

```json
{
  "introduction": {
    "name": "Muhd Hafiz",
    "headline": "Software Engineer / Game Developer",
    "summary": "I build software, games, and data-driven tools.",
    "downloads": [
      {
        "label": "Resume",
        "url": "https://example.com/resume.pdf",
        "external": true
      }
    ]
  },
  "experience": [
    {
      "start": "2024-01",
      "end": "2025-12",
      "title": "Software Engineer Intern",
      "company": "Example Corp",
      "icon": "assets/svg/work-eon.png",
      "bullets": [
        "Built internal tools in Flutter and Python.",
        "Improved CI build reliability."
      ]
    }
  ],
  "education": [
    {
      "start": "2021-04",
      "end": "2024-03",
      "school": "Example Polytechnic",
      "course": "Diploma in AI and Analytics",
      "final_gpa": "3.80",
      "icon": "assets/svg/school-nyp.png",
      "modules": [
        {
          "name": "Core",
          "items": ["Data Structures", "Machine Learning"]
        }
      ]
    }
  ],
  "skills": {
    "Languages": {
      "description": "Primary languages used in projects.",
      "related_projects": ["ai-game-project"],
      "items": ["Python", "Dart", "C++"]
    }
  }
}
```

Notes:
- Code expects `downloads[].label` (not `key`) in landing intro.
- Experience/education keys are `start` and `end` in current parser.
- Skills supports map-style categories; parser also has backward-compatible list handling.
