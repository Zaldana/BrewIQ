# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

BrewIQ is a SwiftUI-based iOS coffee brewing calculator that helps users brew coffee with precise coffee-to-water ratios. Built with SwiftUI and SwiftData, it supports 12 predefined brewing methods, custom ratios, and user-created brew methods.

**Tech Stack**: Swift, SwiftUI, SwiftData (iOS persistence)

## Essential Commands

### Opening and Building
```bash
# Open project in Xcode
open BrewIQ.xcodeproj

# Build the project (requires Xcode, not just Command Line Tools)
xcodebuild -project BrewIQ.xcodeproj -scheme BrewIQ -configuration Debug build

# Run all tests
xcodebuild test -project BrewIQ.xcodeproj -scheme BrewIQ -destination 'platform=iOS Simulator,name=iPhone 15'

# Run tests from Xcode (alternative if xcodebuild fails)
# Open project and use Cmd+U
```

### Testing Individual Components
Tests use Swift Testing framework (`@Test` macro, not XCTest). To test specific components:
```bash
# Run all tests
xcodebuild test -project BrewIQ.xcodeproj -scheme BrewIQ -destination 'platform=iOS Simulator,name=iPhone 15'
```

Individual test structs in `BrewIQTests/BrewIQTests.swift`:
- `BrewMethodTests` - Tests for brew method ratios and metadata
- `WaterUnitTests` - Unit conversion tests (ml, oz, cups)
- `BrewCalculatorViewModelTests` - Core calculation logic tests
- `BrewStrengthTests` - Brew strength enum tests

## Architecture Overview

### Data Flow Pattern
The app uses **SwiftData** for persistence with **@Observable** for reactive state management:

1. **App Entry** (`BrewIQApp.swift`): Creates shared `ModelContainer` with schema for `UserPreferences` and `CustomBrewMethod`
2. **Root View** (`ContentView.swift`): Shows `SplashView`, applies theme from `UserPreferences`
3. **Main Flow**: `SplashView` → `BrewCalculatorView` (main calculator interface)
4. **Data Access**: Views use `@Query` to fetch `UserPreferences`, `@Environment(\.modelContext)` to modify data

### SwiftData Persistence
All user customizations are stored via SwiftData:

- **`UserPreferences`** (`@Model`): Stores selected brew methods (max 9), custom ratios per method, custom brew notes, app theme, and custom methods array
- **`CustomBrewMethodData`** (nested in `UserPreferences`): User-created brew methods with custom name, icon, and ratios
- **`CustomBrewMethod`** (`@Model`): Legacy model (exists but may not be actively used - check before modifying)

**Important**: SwiftData models use `@Model` macro. The ModelContainer is configured with error recovery (deletes store and recreates on migration failures).

### State Management
- **`@Observable`**: Used for ViewModels (e.g., `BrewCalculatorViewModel`) - modern SwiftUI observable pattern
- **`@Query`**: SwiftData query for reactive access to persisted models
- **`@Environment(\.modelContext)`**: Access to SwiftData context for inserts/saves
- **`@State`**: For local view state

### Key Models

**`BrewMethod`** (enum, 12 cases): Defines all predefined brew methods with:
- `ratio(for:)` method returning water:coffee ratio for each strength
- `icon` property (SF Symbol name)
- `brewNotes` property (brewing instructions)

**`BrewStrength`** (enum): `.mild`, `.medium`, `.bold` - affects ratios

**`WaterUnit`** (enum): `.milliliters`, `.ounces`, `.cups` - water measurement units with conversion methods

**`UserPreferences.CustomRatio`** (struct, Codable): Stores `mild`, `medium`, `bold` ratio overrides per brew method

### Color System
Custom color theme in `Models/ColorTheme.swift`:
- Uses extension on `Color` with light/dark/high-contrast variants
- Colors: `brewPrimary` (mint blue), `brewSecondary` (grey), `brewBackgroundTop/Bottom` (gradient), etc.
- **WCAG AA compliant** for accessibility
- Applied via `LinearGradient` backgrounds and semantic color names

### View Structure
- **`BrewCalculatorView`**: Main calculator with method selection, strength selection, coffee/water inputs
  - Displays up to 9 user-selected brew methods
  - Shows calculated coffee (from water input) OR calculated water (from coffee input)
  - Accordion-style "Brew Notes" section per method
  - Uses custom components: `InputCard`, `CompactStrengthButton`, `CompactMethodButton`
  
- **`CustomizationView`**: Settings and customization interface (opened via customize icon)
  - Theme selection (Light/Dark/Auto)
  - Brew method selection (toggle up to 9 methods)
  - Ratio customization per method with reset-to-default
  - Custom brew notes per method
  - Add/delete custom brew methods

- **`SplashView`**: App launch screen (automatically transitions to `BrewCalculatorView`)

## Critical Implementation Notes

### SwiftData Save Pattern
Always save after modifying `UserPreferences`:
```swift
userPrefs.selectedMethodRawValues = newValues
try? modelContext.save()
```

### Custom Brew Methods
Custom methods are stored in `UserPreferences.customMethods: [CustomBrewMethodData]`. Each has:
- `id: UUID`
- `name: String` (max 15 chars for UI fit)
- `icon: String` (SF Symbol name from predefined list)
- `ratioMild`, `ratioMedium`, `ratioBold: Double`

Available custom icons: `mug.fill`, `cup.and.saucer.fill`, `drop.fill`, `sparkles`, `star.fill`, `heart.fill`, `leaf.fill`, `flame.fill`

### Ratio Calculation Logic
Coffee/water calculations in `BrewCalculatorViewModel`:
- Coffee input is always in **grams**
- Water uses selected unit (ml, oz, cups), converted to grams (1ml ≈ 1g)
- Formula: `waterInGrams = coffeeInGrams * ratio` OR `coffeeInGrams = waterInGrams / ratio`
- Custom ratios (from `UserPreferences`) override default ratios

### User Preferences Initialization
If no `UserPreferences` exist, views create one with default selected methods:
```swift
private var userPrefs: UserPreferences {
    if let prefs = preferences.first {
        return prefs
    } else {
        let newPrefs = UserPreferences()
        modelContext.insert(newPrefs)
        return newPrefs
    }
}
```

Default selected methods: French Press, Moka Pot, Drip Coffee, AeroPress, Siphon Coffee, Chemex, Hario V60, Clever Dripper, Pour Over

## Common Development Patterns

### Adding New Brew Methods
1. Add case to `BrewMethod` enum in `Models/BrewMethod.swift`
2. Add ratio logic in `ratio(for:)` switch
3. Add icon in `icon` computed property
4. Add brew notes in `brewNotes` computed property
5. Update tests in `BrewIQTests/BrewIQTests.swift`

### Modifying SwiftData Schema
**Warning**: Schema changes can break existing user data. The app has error recovery (deletes and recreates store), but users lose data.
- Test migrations thoroughly
- Consider adding migration logic in `BrewIQApp.swift` if data must be preserved
- Increment schema version or handle versioning carefully

### Testing Calculations
All core calculation logic is in `BrewCalculatorViewModel` with comprehensive test coverage. When modifying:
1. Update `BrewCalculatorViewModel.swift`
2. Add/update tests in `BrewCalculatorViewModelTests` struct
3. Verify water unit conversions still work (`WaterUnitTests`)

### UI Customization
- Colors: Modify `Models/ColorTheme.swift` - maintain WCAG AA contrast ratios
- Layouts: Main views are in `Views/` directory
- Custom components are defined inline in view files (e.g., `InputCard`, `CompactMethodButton` in `BrewCalculatorView.swift`)

## Project Constraints

- **Max Brew Methods**: 9 displayed at once (enforced in `CustomizationView`)
- **Custom Method Name Length**: 15 characters (UI constraint)
- **Water Unit Conversions**: 1 fl oz = 29.5735 mL, 1 cup (4oz) = 118.294 mL, 1 mL water ≈ 1g
- **Coffee Unit**: Always grams (no conversion needed)
- **iOS Target**: iOS only (SwiftUI + SwiftData, no macOS/watchOS)

## Known Issues & Quirks

1. **xcodebuild vs Xcode**: Command may fail if only Command Line Tools installed (needs full Xcode)
2. **ModelContainer Recovery**: App deletes SwiftData store on migration failure - no user data recovery
3. **Custom Method Limit**: No enforced limit on custom methods (only displayed methods limited to 9)
4. **Legacy Model**: `CustomBrewMethod.swift` exists but may be unused (verify before modifying)

## Files to Check Before Major Changes

- `BrewIQApp.swift` - App entry, ModelContainer setup
- `Models/UserPreferences.swift` - All persistence schema
- `Models/BrewMethod.swift` - Default ratios and brew method definitions
- `ViewModels/BrewCalculatorViewModel.swift` - Core calculation logic
- `BrewIQTests/BrewIQTests.swift` - Test coverage
