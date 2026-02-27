# AGENTS.md

This is a data-driven Flutter Web portfolio site. All content comes from JSON assets in `assets/`. The architecture uses feature-based organization with reusable widgets, responsive utilities, and centralized theming.

### Do
- use `lib/core/theme.dart` for all colors, gradients, and text styles. no hard-coded values
- use `lib/core/responsive_web_utils.dart` for responsive layout decisions. check `isMobile()` before conditional rendering
- keep widgets small and composable. prefer `lib/widgets/generic/`, `lib/widgets/project/`, or `lib/widgets/website/` subdirectories
- pass data explicitly as parameters rather than storing state in widgets
- use `ProjectService.getProjectsForPage()` to fetch filtered project lists
- reference images in `assets/projects.json` without the `assets/` prefix (e.g., `"images/games/project.png"`)
- add new pages by editing `assets/page_config.json`, then `AppRoutes.initialize()` handles slug generation
- default to small components focused on a single responsibility

### Don't
- do not hard-code colors or theme values. use `AppColors` from `lib/core/theme.dart`
- do not create custom responsive logic. use `ResponsiveWebUtils.isMobile(context)` from `lib/core/responsive_web_utils.dart`
- do not store project data or page config in code. keep everything in `assets/`
- do not create large monolithic widgets. extract sub-widgets into separate files
- do not skip null checks on optional fields like `vid_link`, `github_link`, or `download_paths` from JSON
- do not modify `variable_name` in `assets/projects.json` after creation (it's used for URL slugs)

### Commands

```
# Type check a single file
dart analyze path/to/file.dart

# Format a single file
dart format path/to/file.dart

# Lint a single file
flutter analyze path/to/file.dart

# Build web when explicitly requested
flutter build web
```

Note: Always format and analyze updated files. Run full build only when explicitly requested.

### Safety and permissions

Allowed without prompt:
- read files, list files
- dart analyze, dart format
- flutter pub get

Ask first:
- flutter pub add (adding dependencies)
- flutter build web
- deleting files
- git push

### Project structure

- `lib/main.dart` - app entry point, routing setup, initialization
- `lib/core/routes.dart` - URL routing and page slug generation (uses AppRoutes)
- `lib/core/theme.dart` - all colors, gradients, and text styling (use for all UI constants)
- `lib/core/responsive_web_utils.dart` - mobile detection and responsive breakpoints (use for layout decisions)
- `lib/pages/` - full-page components (LandingPage, ProjectsBasePage, ProjectDetailPage)
- `lib/widgets/generic/` - reusable widgets (ImageGallery, YoutubeVideoPlayer, SearchBar, SharedTabs)
- `lib/widgets/website/` - site-level components (CustomAppBar, CustomFooter, Timeline)
- `lib/widgets/project/` - project display widgets (PreviewCard, ListItem, FullDetailCard, ThumbnailPreview)
- `lib/widgets/ui/` - UI utilities (HoverCard, AnimatedGradient)
- `lib/services/project_service.dart` - data fetching and filtering
- `lib/utils/` - data models and utilities (ProjectData, PageCollection, LandingPageData)
- `assets/page_config.json` - page definitions and navigation
- `assets/projects.json` - all project content (versions, tags, links, images)
- `assets/landing_page.json` - intro, experience, education, skills
- `assets/images/` - organized by category (games, other, sit)

### Good and bad examples

- ✅ follow `lib/widgets/project/project_preview_card.dart` for composable card widgets
- ✅ follow `lib/widgets/generic/image_gallery.dart` for complex UI components
- ✅ follow `lib/pages/projects_base_page.dart` for page filtering and selection
- ❌ avoid creating custom color values. see `AppColors` in `lib/core/theme.dart` for available colors
- ❌ avoid responsive conditionals without `ResponsiveWebUtils.isMobile()`. it centralizes breakpoint logic
- ❌ avoid fetching projects directly. use `ProjectService` methods instead

### Data sources

All content is JSON-driven:

- `assets/projects.json`: `{ projectId: { variable_name, page_list[], shown, default_version, versions[] } }`. Each version has title, description, date, last_update, img_paths[], tags[], github_link, vid_link, download_paths[]. Set `show_in_timeline` to control timeline visibility.
- `assets/page_config.json`: `{ project_pages: [ { page_name, description, default_list_view, dropdown } ] }`. Page slugs generated from page_name by `AppRoutes.slugForPageName()`.
- `assets/landing_page.json`: `{ introduction, experience[], education[], skills }`. Renders on `/`.

### Key core files

- `lib/core/theme.dart` - app theming. Always use `AppColors`, gradients, and `textTheme` from here. Do not create inline colors.
- `lib/core/responsive_web_utils.dart` - responsive detection. Use `ResponsiveWebUtils.isMobile(context)` for all mobile/desktop decisions.
- `lib/core/routes.dart` - routing and slug generation. See `AppRoutes.initialize()` and `genericPageSlugs` for page mapping.

### How to add or edit content

**Add a new project:**
1. Add entry in `assets/projects.json` with unique `projectId` and `variable_name`
2. Add version(s) with title, description, date, images, links
3. Set `page_list: ["Featured"]` if it should show on Featured page
4. Set `shown: true` to make it visible
5. Add images to `assets/images/<category>/` and reference without `assets/` prefix

**Add a new page:**
1. Add object in `assets/page_config.json` under `project_pages` with `page_name`, `description`
2. `AppRoutes.initialize()` auto-generates slug and routing
3. Update projects' `page_list` to include the new `page_name`
4. `CustomAppBar` auto-updates navigation

**Edit landing content:**
- Update `assets/landing_page.json`. `LandingPage` reads and renders dynamically.

### When stuck
- ask a clarifying question, propose a short plan, or check if data is missing/malformed in JSON
- verify JSON schema before assuming code is broken (missing keys, wrong types, empty arrays)
- check `ProjectService` to understand how data flows from assets to pages
