# Copilot Instructions for CBLuna Dashboard Demos

## Project Overview
**CBLuna Dashboard Demos** is a cross-platform Flutter demo application (Web, Windows, iOS, Android, macOS, Linux) showcasing multiple interactive dashboards with different themes and data visualization styles. Built with Provider state management, responsive design, and advanced chart/graph components. **This is a pure demo application with hardcoded data - NO backend connections, NO authentication, NO data persistence.**

**Purpose**: Demonstrate CBLuna's dashboard creation capabilities through varied, visually-appealing examples of business intelligence interfaces.

## Architecture Patterns

### State Management
- **Provider Pattern**: Uses `provider: ^6.1.1` for dependency injection and state management
- **Key Providers** (in `lib/providers/`):
  - `DashboardNavigationProvider()`: Handles switching between different dashboards
  - `ThemeProvider()`: Manages dynamic theme changes per dashboard
  - Demo-specific providers for UI state only
- **Setup**: Providers are registered in `main()` via `MultiProvider` before app initialization
- Reference: [lib/main.dart](lib/main.dart)

### Routing
- **Router**: `go_router: ^14.8.1` for declarative navigation
- **Key Config**: Single router file at [lib/router/router.dart](lib/router/router.dart)
- **URL Strategy**: Uses `url_strategy: ^0.2.0` to remove `#` from web URLs (configured in `main()`)
- **No Authentication**: Direct access to dashboard view - no login required
- Routes: `/` (main dashboard container), `/dashboard/:dashboardId`, external redirect to `https://cbluna.com/`

### Theme System
- **Dynamic Theming**: Each dashboard has its own color palette and visual identity
- **Dashboard Themes**:
  - Sales Dashboard: Professional blue/green corporate (#2563EB, #10B981)
  - Video Content Dashboard: Purple/pink creative (#8B5CF6, #EC4899)
  - Additional dashboards: Unique palettes matching their domain
- **Light/Dark Modes**: All dashboards support both modes with appropriate color adjustments
- **Storage**: Theme preference saved via `SharedPreferences` under key `__theme_mode__`
- **Theme Switching**: Automatically changes when navigating between dashboards
- Font: Uses `google_fonts: ^6.2.1` with Poppins as primary font

### Data Layer (Mock/Hardcoded)
- **Mock Data**: All data in [lib/data/mock_data.dart](lib/data/mock_data.dart)
  - Sales dashboard: Revenue, clients, sales trends, KPIs (20-30 records)
  - Video dashboard: Views, top videos, categories, subscribers (15-25 records)
  - Additional dashboard data as needed
- **No Persistence**: Changes exist only in memory during session
- **No Backend**: Zero API calls, zero database queries
- **Models**: Simplified models in [lib/models/](lib/models/) for demo data structure

## Project Structure

```
lib/
├── main.dart              # App entry, MultiProvider setup
├── data/                  # Mock/hardcoded data
│   ├── mock_data.dart     # All demo data (sales, videos, KPIs)
│   ├── sales_data.dart    # Sales dashboard specific data
│   └── video_data.dart    # Video content dashboard data
├── functions/             # Pure utility functions (formatting, validation)
├── helpers/               # Shared utilities and constants
│   ├── constants.dart     # Demo constants (breakpoints, dashboard IDs)
│   ├── globals.dart       # Global state (prefs, navigation keys)
│   └── color_extension.dart, scroll_behavior.dart
├── internationalization/  # i18n with intl package (multi-language support)
├── models/                # Simplified Dart models (SalesSummary, VideoStats, etc.)
├── pages/                 # Full-page widgets (dashboard container)
│   ├── dashboard_container/  # Main container with sidebar
│   ├── dashboards/          # Individual dashboard pages
│   │   ├── sales_dashboard/
│   │   ├── video_dashboard/
│   │   └── ...
│   └── page_not_found/      # 404 fallback
├── providers/             # ChangeNotifier providers for UI state
│   ├── dashboard_navigation_provider.dart  # Dashboard switching
│   └── theme_provider.dart                 # Dynamic theme management
├── router/                # GoRouter configuration
├── theme/                 # Theme definitions, dynamic color palettes
│   ├── theme.dart         # Base theme system
│   ├── dashboard_themes.dart  # Individual dashboard color schemes
│   └── theme_provider.dart    # Theme switching logic
└── widgets/               # Reusable UI components
    ├── sidebar/           # Sidebar navigation widget
    ├── kpi_card.dart      # KPI display cards
    ├── chart_widgets/     # Chart/graph components
    └── ...
```

## Critical Dependencies & Integration Points

### UI Libraries
- **fl_chart**: Chart rendering for dashboard graphs and data visualization
- **google_fonts**: Typography via Poppins font
- **provider**: State management
- **go_router**: Navigation and routing
- **shared_preferences**: Theme mode persistence only

### Demo-Specific
- **No external services**: All third-party services removed
- **No authentication**: Direct access to dashboards
- **No persistence**: All changes in memory only
- **Responsive**: Mobile breakpoint at 768px
- **External redirect**: Exit button redirects to https://cbluna.com/

## Important Conventions

### Naming & Organization
- **Files**: `snake_case.dart` for files, camelCase for classes/variables
- **Imports**: Group as (1) dart:, (2) package:flutter, (3) package:third_party, (4) relative imports
- **Constants**: All caps with underscores (e.g., `kThemeModeKey`, `organizationId`)

### State Updates
- **Never mutate**: Always create new instances or use `notifyListeners()` in ChangeNotifiers
- **Build context usage**: Pass context when needed for theme/localization, avoid storing globally
- **Disposal**: Remember to dispose listeners/controllers in `dispose()` methods

### Error Handling
- **No network errors**: No API calls to fail
- **UI feedback**: Use `snackbarKey` (GlobalKey in globals.dart) for user messages
- **Validation**: Client-side only (email format, required fields)

## Build & Deployment

### Commands
```bash
# Clean & prepare
flutter clean && flutter pub get

# Windows debug/release
flutter run -d windows
flutter build windows --release

# Web deployment
flutter build web --release
# Output: build/web/ (serve with static hosting)

# Mobile builds
flutter build apk --release      # Android
flutter build ios --release      # iOS
```

### Important Notes
- **Windows symlink issue**: If you get `ephemeral\.plugin_symlinks` errors, run `flutter clean`
- **Web**: Check `build/web/index.html` for configuration after build
- **Intl override**: Project requires `intl: ^0.19.0` due to pluto_grid compatibility

## Common Workflows

### Adding a New Page
1. Create widget in `lib/pages/my_page.dart` extending `StatelessWidget` or `StatefulWidget`
2. Add route to [lib/router/router.dart](lib/router/router.dart) with GoRoute configuration
3. If needs state: Create provider in `lib/providers/` extending `ChangeNotifier`
4. Register provider in `main()` `MultiProvider` list if global, or wrap page with `ChangeNotifierProvider` if local

### Adding Mock Data
1. Define model in `lib/models/` with simple Dart classes
2. Add data to [lib/data/mock_data.dart](lib/data/mock_data.dart) as static lists
3. Import and use directly in widgets or providers
4. Remember: Changes are in-memory only, no persistence

### Styling Pages
- Use `AppTheme.of(context)` to get current theme colors/styles
- Reference [lib/theme/theme.dart](lib/theme/theme.dart) for available color properties
- Responsive breakpoint: `mobileSize = 768` pixels (check in [lib/helpers/constants.dart](lib/helpers/constants.dart))

## What You MUST Know Before Coding

1. **No backend**: This is a pure demo - no APIs, no database, no real persistence
2. **Mock data only**: All data in [lib/data/mock_data.dart](lib/data/mock_data.dart) - changes live in memory
3. **No authentication**: Direct access to dashboards - no login page
4. **Dynamic theming**: Each dashboard has unique color palette that switches automatically
5. **Sidebar navigation**: Fixed sidebar with dashboard list + exit button to https://cbluna.com/
6. **fl_chart**: Primary charting library for graphs and data visualization

## Quick Links
- **Demo Purpose**: Showcase CBLuna's dashboard creation capabilities
- **Design System**: Multiple unique palettes per dashboard (Sales: blue/green, Videos: purple/pink, etc.)
- **Target Audience**: Potential clients evaluating dashboard development services
- **Main Site**: https://cbluna.com/ (exit button destination)
