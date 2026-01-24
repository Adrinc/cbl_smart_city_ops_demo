# Copilot Instructions for DemoCorp CRM

## Project Overview
**DemoCorp CRM** is a cross-platform Flutter demo application (Web, Windows, iOS, Android, macOS, Linux) showcasing a professional CRM system. Built with Provider state management, responsive design, and advanced UI components. **This is a demo application with hardcoded data - NO backend connections, NO real authentication, NO data persistence.**

## Architecture Patterns

### State Management
- **Provider Pattern**: Uses `provider: ^6.1.1` for dependency injection and state management
- **Key Providers** (in `lib/providers/`):
  - `VisualStateProvider()`: Handles UI state, dark/light theme, visual preferences
  - Demo-specific providers for UI state only
- **Setup**: Providers are registered in `main()` via `MultiProvider` before app initialization
- Reference: [lib/main.dart](lib/main.dart)

### Routing
- **Router**: `go_router: ^14.8.1` for declarative navigation
- **Key Config**: Single router file at [lib/router/router.dart](lib/router/router.dart)
- **URL Strategy**: Uses `url_strategy: ^0.2.0` to remove `#` from web URLs (configured in `main()`)
- **Fake Auth**: Simple redirect logic - no real authentication, just checks for mock user in memory
- Routes: `/login`, `/dashboard`, `/clients`, `/employees`, `/locked-features`

### Theme System
- **Static Theming**: Professional corporate colors (Blue #2563EB primary)
- **Light/Dark Modes**: `AppTheme.lightTheme` and `AppTheme.darkTheme` with static colors
- **Storage**: Theme preference saved via `SharedPreferences` under key `__theme_mode__`
- **No External Config**: All colors hardcoded in [lib/theme/theme.dart](lib/theme/theme.dart)
- Font: Uses `google_fonts: ^6.2.1` with Poppins as primary font

### Data Layer (Mock/Hardcoded)
- **Mock Data**: All data in [lib/data/mock_data.dart](lib/data/mock_data.dart)
  - Clients list (20-30 records)
  - Employees list (10-15 records)
  - Dashboard KPIs and metrics
  - Recent activities
  - Company info: "DemoCorp"
- **No Persistence**: Changes exist only in memory during session
- **No Backend**: Zero API calls, zero database queries
- **Models**: Simplified models in [lib/models/](lib/models/) for demo data structure

## Project Structure

```
lib/
├── main.dart              # App entry, MultiProvider setup
├── data/                  # Mock/hardcoded data (NEW)
│   └── mock_data.dart     # All demo data (clients, employees, KPIs)
├── functions/             # Pure utility functions (formatting, validation)
├── helpers/               # Shared utilities and constants
│   ├── constants.dart     # Demo constants (company name, breakpoints)
│   ├── globals.dart       # Global state (mockUser, prefs)
│   └── color_extension.dart, scroll_behavior.dart
├── internationalization/  # i18n with intl package (multi-language support)
├── models/                # Simplified Dart models (Client, Employee, etc.)
├── pages/                 # Full-page widgets (routes)
│   ├── login_page/        # Fake login (any credentials work)
│   ├── dashboard_page/    # Main landing with KPIs
│   ├── clients_page/      # Client CRUD (memory only)
│   ├── employees_page/    # Employee management
│   └── locked_feature/    # Placeholder for premium features
├── providers/             # ChangeNotifier providers for UI state only
├── router/                # GoRouter configuration
├── theme/                 # Theme definitions, hardcoded colors
└── widgets/               # Reusable UI components
```

## Critical Dependencies & Integration Points

### UI Libraries
- **pluto_grid**: Data table widget (requires `intl: ^0.19.0` override)
- **fl_chart**: Chart rendering for dashboard
- **google_fonts**: Typography via Poppins font
- **provider**: State management
- **go_router**: Navigation and routing

### Demo-Specific
- **No external services**: Stripe, N8N, Supabase removed
- **No authentication**: Login always succeeds
- **No persistence**: All changes in memory only
- **Responsive**: Mobile breakpoint at 768px

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

1. **No backend**: This is a pure demo - no Supabase, no API calls, no real persistence
2. **Dependency override**: `intl: ^0.19.0` is intentionally pinned - don't upgrade without testing pluto_grid
3. **Mock data only**: All data in [lib/data/mock_data.dart](lib/data/mock_data.dart) - changes live in memory
4. **Fake authentication**: Login accepts any credentials - no validation
5. **Static theming**: Colors are hardcoded corporate blue (#2563EB) - no dynamic themes

## Quick Links
- **Demo Purpose**: Showcase CRM capabilities without backend complexity
- **Design System**: Professional blue/green corporate palette
- **Target Audience**: Potential clients evaluating CRM features
