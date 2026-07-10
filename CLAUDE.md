# AGENTS.MD

This document reflects how the codebase currently works.

## Compatibility Policy

- Backward compatibility is intentionally not supported.
- Data contracts (the shape of rows in Supabase's `projects` table) are strict; legacy shapes should not be parsed or preserved.
- When implementing updates, do not spend effort on backward-compatible behavior.

## Stack

| Layer | Technology |
|---|---|
| Language | Dart 3.9+ |
| Framework | Flutter (web target) |
| UI | Material 3 (`useMaterial3: true`) |
| Fonts | Google Fonts `Inter` |
| Routing | `MaterialApp.onGenerateInitialRoutes` + `onGenerateRoute` + path URL strategy |
| Data | Supabase Postgres table `projects`, read via raw PostgREST calls (`lib/data/supabase/supabase_rest.dart`), no `supabase_flutter` SDK |
| Images | Supabase Storage (bucket `project-images`), served as public URLs; only 4 fixed UI icons remain bundled locally |

## Data now lives in Supabase, not local assets

As of this migration, `assets/projects/`, `assets/images/` (per-project folders), `assets/page_config.json`, and `assets/landing_page.json` **no longer exist in this repo**. All project metadata, page config, landing page content, and project/icon images are edited through a separate local tool (`portfolio-site-uploader`, a Flask app in a sibling repo) and pushed to Supabase from there. This app only ever *reads* from Supabase at runtime — there is no local editing path anymore, and no rebuild is needed to change content.

- **Connection**: `lib/core/supabase_config.dart` hardcodes the project URL and the **publishable/anon key** (safe to be public — RLS restricts it to read-only).
- **Client**: `lib/data/supabase/supabase_rest.dart` (`SupabaseRest.fetchAll`/`fetchById`) is a minimal hand-rolled PostgREST client using `package:http`, not the full `supabase_flutter` SDK — this project only needs read access, so the lighter dependency was chosen deliberately.
- **Table shape**: single table `projects`, columns `id text primary key` and `data jsonb`. Most rows are actual projects (`id` = the project's slug). Two reserved rows hold site-wide content, using ids that can never collide with a real slug (slugs never start with `_`):
  - `_page_config` → `data` shaped like the old `page_config.json` (`{ "project_pages": [...] }`)
  - `_landing_page` → `data` shaped like the old `landing_page.json`
- **RLS**: the `projects` table has Row Level Security enabled with a single `SELECT`-only policy for the `anon` role. The publishable key can read but never write. The uploader tool writes using the Supabase **secret key**, which bypasses RLS — that key only ever lives in the uploader's own `.env`, never in this repo.
- Rows are only ever pushed by the uploader tool; this app's code has no write path to Supabase at all.

## Startup and Routing

Startup flow in `lib/main.dart`:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `usePathUrlStrategy()`
3. `await Future.wait([ProjectsCollection.initializeFromSupabase(), AppRoutes.initialize()])`
4. `runApp(const PortfolioApp())`

`AppRoutes.initialize()` in `lib/core/routes.dart` loads `PageCollection` and builds `genericPageSlugs` (`slug -> page_name`).

Routing is handled in `MaterialApp.onGenerateInitialRoutes` and `MaterialApp.onGenerateRoute`:

- Initial URL canonicalization (single initial route, no extra `/` route in stack):
  - `/` -> `/home`
  - Any unknown path -> `/404`
- `/home` -> `LandingPage`
- `/404` -> `NotFoundPage`
- `/projects` and `/projects/` -> `ProjectSummaryPage`
- `/projects/<slug>` -> resolves slug from `AppRoutes.genericPageSlugs`, then builds `ProjectsBasePage`
- `/project/<slug>` -> `ProjectDetailPage(slug: slug)`
- Any unmatched runtime navigation route -> URL is replaced to `/404`, then `NotFoundPage` is shown

Navigation UI in `lib/widgets/ui/custom_app_bar.dart` is currently fixed to two links:

- `Home` -> `/home`
- `Projects` -> `/projects/`

## Data Layer

### Projects

- Source: Supabase `projects` table, all rows except `_page_config`/`_landing_page`
- Loader: `ProjectsCollection.initializeFromSupabase()`
- Singleton: `ProjectsCollection.instance`
- Models: `ProjectEntry` and `ProjectData` in `lib/data/projects/project_data.dart`

Important behavior:

- `ProjectEntry` supports multiple versions and a `default_version`
- Slug comes from `ProjectData.slug`, which is based on `variable_name` (fallback `title`) — this is also the Supabase row's `id`
- `shown` and `show_in_timeline` flags are enforced in UI/data assembly
- `img_paths` on Supabase-sourced data are full `https://...supabase.co/storage/...` public URLs, not relative paths — see "Image loading" below

### Pages

- Source: Supabase `projects` row `id = '_page_config'`
- Loader: `PageCollection.initializeFromSupabase()`
- Singleton: `PageCollection.instance`
- Model: `ProjectPageData` (`page_name`, `description`, `all_projects`)

### Landing

- Source: Supabase `projects` row `id = '_landing_page'`
- Loader: `LandingPageData.loadFromSupabase()` (currently called from `LandingPage.initState`)
- Model: `lib/data/landing/landing_page_data.dart`

Current landing JSON keys expected by code:

- `introduction`: `name`, `headline`, `summary`, `downloads[{label,url}]`
- `experience[]`: `start`, `end`, `title`, `company`, `icon`, `bullets[]`
- `education[]`: `start`, `end`, `school`, `course`, `final_gpa`, `icon`, `modules[{name,items[]}]`
- `skills`: map of category -> `{description, related_projects[], items[]}` — `related_projects` values are project **slugs** (e.g. `"nyp-ai-game"`), not the old pre-migration `id` style (`"NYP-AIGame"`)
- `experience[].icon` / `education[].icon`: either a Supabase Storage public URL (uploaded via the uploader tool) or empty string; the 4 originally-bundled icon PNGs were migrated to Storage — nothing under `assets/svg/` is referenced from landing data anymore

## Image loading

`lib/core/adaptive_image.dart` provides `buildAdaptiveImage()` and `buildAdaptiveSvg()`, used everywhere an `img_paths` entry or an `icon` field is rendered (`project_thumbnail_preview.dart`, `image_gallery.dart`, `landing_work_card.dart`, `landing_education_card.dart`, `timeline_tooltips.dart`). Each picks `Image.network`/`SvgPicture.network` vs `Image.asset`/`SvgPicture.asset` based on `isNetworkImagePath()` (starts with `http://`/`https://`). In practice, every path from Supabase is a network URL now — the asset-path branch is really only a safety fallback.

`buildAdaptiveImage` uses `frameBuilder` (not `loadingBuilder`) to show a spinner while a network image decodes — `loadingBuilder`'s chunk-progress events don't fire reliably on Flutter Web, so `frameBuilder`'s `frame == null` check is used instead. Don't switch this back to `loadingBuilder` for the web-only "show a spinner while loading" behavior; it silently does nothing on web.

Images are pushed as WebP (quality 90) by the uploader tool regardless of their local source format, with a 1-year `Cache-Control` — this app doesn't need to think about image format, just render whatever URL Supabase gives it.

## Service Layer

Primary project read API is `ProjectService` (`lib/data/projects/project_service.dart`):

- `getProjectsForPage(pageName, descending: true)`
- `getProjectSortDate(project)` returns the effective sort date (`last_update` fallback `date`)
- `getProjectEntryBySlug(slug)`
- `getProjectBySlug(slug)`
- `searchProjects(query)`
- `getAllTags()`, `getAllTools()`

Filtering on tags/type/tools/search for `ProjectsBasePage` is currently done in-page after fetching page projects.

## UI Architecture

Core pages:

- `lib/pages/landing_page.dart`
- `lib/pages/project_summary_page.dart`
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

This section maps widget responsibilities and current usage.

### UI Shell Widgets (`lib/widgets/ui/`)

- `CustomAppBar`
  - Used by: Landing, Project summary page, Projects list page, Project detail page.
  - Responsibility: Shared top nav with only `Home` and `Projects` links on desktop and mobile.
  - Contract: Navigation currently uses `Navigator.pushNamedAndRemoveUntil(..., (r) => false)` for both links.

- `CustomFooter`
  - Used by: Landing, Project summary page, Projects list page, Project detail page.
  - Responsibility: Shared social CTA and external links (LinkedIn, YouTube, GitHub).
  - Contract: Keep footer globally reusable and safe for both mobile and desktop.

- `AnimatedGradient`
  - Used by: Project cards/list items, timeline containers, work/education/skills cards.
  - Responsibility: Reusable animated gradient background wrapper.
  - Contract: Visual only; should not contain business logic.
  - Current behavior: supports configurable `borderRadius`, `borderColor`, and `borderWidth`.
  - Defaults: if not provided, it renders with `BorderRadius.zero`, `Colors.black12`, and `1px` border width.
  - Styling intent:
    - landing page section cards should stay hard-edged (`BorderRadius.zero`)
    - project summary page sections currently use rounded corners
    - use explicit parameters at call sites instead of wrapping `AnimatedGradient` in extra containers just to fake border styling

- `HoverCardWidget`
  - Used by: `ProjectPreviewCard`, `ProjectListItem`, `ProjectCompactCard`.
  - Responsibility: Shared hover lift/scale + material ink behavior for clickable cards on web.
  - Contract: Preserve clickability and hover affordance.

- `GradientScaffold` (`lib/core/theme.dart`)
  - Used by: All top-level pages.
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
  - Used by: `LandingSkillsSection`, `ProjectSummaryPage`.
  - Responsibility: Reusable horizontal carousel for `ProjectCompactCard` items.
  - Contract: Sizing is controlled by explicit `cardWidth` (+ height constraints), not items-per-viewport.
  - Interaction: Supports drag/trackpad/mouse drag and includes an always-visible draggable horizontal scrollbar. No custom mouse-wheel-to-horizontal remapping.

### Project Domain Widgets (`lib/widgets/project/`)

- `ProjectPreviewCard`
  - Used by: Projects grid views.
  - Responsibility: Primary card view for project summaries; navigates to `/project/<slug>`.

- `ProjectListItem`
  - Used by: `ProjectsBasePage` list mode (currently the only mode rendered).
  - Responsibility: Dense row-style project summary with left media column and right content column.
  - Current layout order:
    - title + project type badge
    - tags and tools row
    - vignette/summary
    - `what_i_did` bullets (up to 3) + `+N more`
    - updated date pill + icon link buttons

- `ProjectCompactCard`
  - Used by: `ProjectHorizontalCarousel`, `ProjectTooltipWidget` (timeline tooltips).
  - Responsibility: Small clickable project tile with top media, type badge, and compact meta rows.
  - Notes: title/tools rows support automatic horizontal ticker behavior when content overflows; media area consumes remaining height after title/tools block.
  - Current overlays/metadata:
    - top-left badge: project type
    - bottom-right badge: total project versions (`N VERSION(S)`)
    - metadata text includes formatted last updated date (`DD Month YYYY`, from `last_update` fallback `date`)

- `ProjectFullDetailCard`
  - Used by: Project detail page.
  - Responsibility: Full project content sections (meta, gallery, details, tools, tags, downloads), including internal section switchers.

- `ProjectThumbnailPreview`
  - Used by: Project preview/list cards and detail contexts.
  - Responsibility: Shared thumbnail renderer for image-first, YouTube thumbnail fallback, or placeholder.

### Landing Domain Widgets (`lib/widgets/landing/`)

- `LandingIntro`
  - Responsibility: Name/headline/summary/download actions, plus a quick-stats block (top experience/education).
  - Notes: quick-stats blocks render the experience/education `icon` (SVG or raster, same extension-based dispatch as `LandingWorkCard`/`LandingEducationCard`), falling back to `Icons.work_outline`/`Icons.school_outlined` when no icon is set.
  - Notes: date ranges with no `end` (`null` or empty string) must render as "Present", not blank — check `end != null && end!.isNotEmpty` before formatting, since Supabase can return `""` instead of omitting the field.

- `LandingWorkCard`
  - Responsibility: Work experience card rendering.
  - Notes: same "Present" empty-string handling as `LandingIntro` applies to the date range line.

- `LandingEducationCard`
  - Responsibility: Education card + module groups via `SharedTabs`.
  - Notes: same "Present" empty-string handling as `LandingIntro` applies to the date range line.

- `LandingSkillsSection`
  - Responsibility: Skills category tabs, skill badges, related projects integration.
  - Notes: tabs render inside the skills card; related projects render via `ProjectHorizontalCarousel`.
  - Notes: related projects are resolved from `skills.<category>.related_projects` and then sorted newest-first by effective project date (`last_update` fallback `date`), not by JSON list order.

- `TimelineSingleYear`
  - Used by: landing page today.
  - Responsibility: Interactive year-based timeline with project dots + work/education ranges + legend filters.
  - Notes: work/education ranges are day-aware and render through the end of the end month (not just to month start).
  - Notes: range tooltips use `TimelineData.formatRangeDates(start, end, isOngoing: range.isOngoing)` — `TimelineRange.isOngoing` is true when the source `end` date failed to parse (open-ended role), so the tooltip shows "Present" instead of the internal `_endOfCurrentYear()` placeholder used for bar-width layout.
  - Notes: axis reads standard left-to-right (Jan on the left, Dec on the right); month/date-to-x math lives in `_getMonthPosition`/`_getDatePosition` and must stay in sync — both anchor to month-center so range bars and project dots agree. Year navigation: left arrow = previous year, right arrow = next year. An ongoing range's visible bar length is clamped to today's date (not the full year) when the selected year is the current year.

- `TimelineMultiYear`
  - Present but not currently mounted in landing page.
  - Responsibility: Horizontal multi-year timeline variant.
  - Notes: same left-to-right convention as `TimelineSingleYear` — earlier years render left, later years render right (`years` list built ascending from `minYear` to `maxYear`); `_xForDate` and the dot month-position formula mirror `TimelineSingleYear`'s center-anchored math.

- `RangeTooltipWidget`, `ProjectTooltipWidget`, `HoverTooltipWidget` (`timeline_tooltips.dart`)
  - Responsibility: Shared hover tooltip system for timeline ranges and project nodes.
  - Notes: `ProjectTooltipWidget` now reuses a smaller `ProjectCompactCard` visual and is non-clickable inside the tooltip overlay.
  - Notes: timeline tooltip cards pass timeline `start` date into compact-card data so the compact card date label is populated (no `Unknown date`).

### Usage Map (Current)

- Landing page (`landing_page.dart`)
  - `GradientScaffold` + `CustomAppBar` + `CustomFooter`
  - `LandingIntro`, `TimelineSingleYear`, `LandingWorkCard`, `LandingEducationCard`, `LandingSkillsSection`

- Projects base page (`projects_base_page.dart`)
  - `GradientScaffold` + `CustomAppBar` + `CustomFooter`
  - `SearchBarWidget`, `ProjectListItem`
  - Includes breadcrumb (`Projects / <PageName>`) and filter/sort controls
  - No list/grid toggle in current implementation

- Project summary page (`project_summary_page.dart`)
  - `GradientScaffold` + `CustomAppBar` + `CustomFooter`
  - Per-page sections separated by divider lines
  - Each section: heading + two count items (`N project(s)` and `N unique version(s)`) + `View all ->`, description, `ToolBadgeList`, `ProjectHorizontalCarousel`
  - `Featured` section styling:
    - uses a subtle light-yellow animated gradient from `AppColors.featuredSectionGradient`
    - uses a softer gold border/shadow than normal sections
    - keeps the same content structure as other sections; the differentiation is visual only

- Project detail page (`project_detail_page.dart`)
  - `GradientScaffold` + `CustomAppBar` + `CustomFooter`
  - `SharedTabs` (version tabs), `ProjectFullDetailCard`

## Complete Widget Inventory (Current Files)

This is the full widget file map under `lib/widgets/`.

### `lib/widgets/ui`

- `custom_app_bar.dart`: fixed top navigation (`Home`, `Projects`) for desktop and mobile.
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
- `project_compact_card.dart`: compact project tile used in landing skills/project summary carousels and timeline project tooltips.
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
  - Controls: breadcrumb + filter dropdowns + `SearchBarWidget` + sort button
  - Content: `ProjectListItem*` (list only, with per-item bottom spacing of `10`)

- Project summary page (`lib/pages/project_summary_page.dart`)
  - Shell: `GradientScaffold` -> `CustomAppBar` + `CustomFooter`
  - Body: per-page summary sections separated by divider lines
  - Section: heading + two count items (`N project(s)` and `N unique version(s)`) + `View all ->` link, description, deduplicated `ToolBadgeList`, `ProjectHorizontalCarousel`
  - Visual rule: summary sections are rounded; landing-page section cards are not

- Project detail (`lib/pages/project_detail_page.dart`)
  - Shell: `GradientScaffold` -> `CustomAppBar` + `CustomFooter`
  - Body: `SharedTabs` for versions -> `ProjectFullDetailCard`
  - Inside detail: `YoutubeVideoPlayer`, `ImageGallery`, `ToolBadgeList`, tag chips, download buttons

## Exact Data Contracts in Code (Not Aspirational)

All three examples below are the `data` column of a row in Supabase's `projects` table (see "Data now lives in Supabase" above for the `id` scheme). `SupabaseRest.fetchAll('projects')` returns rows shaped `{ "id": "...", "data": {...} }`; the `data` value is what gets passed into each model's `fromJson`.

### Project row (`id` = a project slug, e.g. `nyp-ai-game`) — parsed by `ProjectEntry.fromJson` / `ProjectData.fromJson`

```json
{
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
      "img_paths": [
        "https://<project-ref>.supabase.co/storage/v1/object/public/project-images/ai-game-project/submission/1.webp"
      ],
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
```

Notes:
- No `id` field inside `data` anymore — `ProjectsCollection` uses the Supabase row's `id` column as the map key (`row['id']`), falling back to nothing meaningful if absent (there always is one, since it's the table's primary key).
- Slug is derived from `variable_name`; do not rename it once links are live — renaming it via the uploader tool changes the Supabase row `id` too (it deletes the old row's images/moves them under the new slug's Storage path).
- `versions` is required and must be a non-empty array.
- `download_paths` entries must be objects with non-empty `key` and `url` strings.
- `img_paths` entries are always full Supabase Storage public URLs (`.webp`) in practice — see "Image loading" above for how the UI renders these vs. hypothetical local paths.

### `_page_config` row — parsed by `ProjectPageData.fromJson`

```json
{
  "project_pages": [
    {
      "page_name": "Featured",
      "description": "Highlights from recent work ({count} projects).",
      "all_projects": false
    },
    {
      "page_name": "All Projects",
      "description": "Everything I've built ({count} projects).",
      "all_projects": true
    }
  ]
}
```

Notes:
- `all_projects: true` ignores `page_list` filtering and includes all shown projects.
- Which projects belong to a non-`all_projects` page is edited from the *page's* side in the uploader tool (a project multiselect per page), then written back into each project's own `page_list` — not edited from the project side.

### `_landing_page` row — parsed by `LandingPageData.fromJson`

```json
{
  "introduction": {
    "name": "Muhd Hafiz",
    "headline": "Software Engineer / Game Developer",
    "summary": "I build software, games, and data-driven tools.",
    "downloads": [
      { "label": "Resume", "url": "https://example.com/resume.pdf" }
    ]
  },
  "experience": [
    {
      "start": "2024-01",
      "end": "2025-12",
      "title": "Software Engineer Intern",
      "company": "Example Corp",
      "icon": "https://<project-ref>.supabase.co/storage/v1/object/public/project-images/_icons/work-eon.webp",
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
      "icon": "https://<project-ref>.supabase.co/storage/v1/object/public/project-images/_icons/school-nyp.webp",
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
- Skills supports map-style categories only.
- `skills.<category>.related_projects` values are project **slugs**, matched against `ProjectData.variableName`/`slug` — see `LandingSkillsSection._resolveRelatedProjects` for the exact matching logic.
- `experience[].icon` / `education[].icon` are Supabase Storage public URLs (or empty string) — never a bundled `assets/svg/...` path.
