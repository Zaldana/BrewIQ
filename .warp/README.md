# BrewIQ

A SwiftUI-based iOS coffee brewing calculator and timer app that helps coffee enthusiasts brew the perfect cup with precise measurements and timing.

## Overview

BrewIQ is an iOS application built with SwiftUI and SwiftData that provides:
- **Brew Calculator**: Calculate precise coffee-to-water ratios for various brewing methods
- **Method Customization**: Select up to 9 brew methods to display, customize ratios, and add custom methods
- **Flexible Ratios**: Customize mild, medium, and bold ratios for any brew method with reset-to-default option

## Tech Stack

- **Language**: Swift
- **Framework**: SwiftUI
- **Data**: SwiftData (for persistent storage)
- **Platform**: iOS (Xcode project)

## Project Structure

```
BrewIQ/
├── BrewIQ/
│   ├── BrewIQApp.swift          # Main app entry point
│   ├── ContentView.swift         # Root view
│   ├── Models/                   # Data models
│   │   ├── BrewMethod.swift      # Brewing method enum with ratios
│   │   ├── BrewStrength.swift    # Strength preferences
│   │   ├── ColorTheme.swift      # Theme options
│   │   ├── CustomBrewMethod.swift # User-defined methods
│   │   ├── MeasurementUnit.swift # Unit conversions
│   │   └── UserPreferences.swift # Settings model
│   ├── ViewModels/               # Business logic
│   │   └── BrewCalculatorViewModel.swift
│   └── Views/                    # UI components
│       ├── BrewCalculatorView.swift
│       └── CustomizationView.swift
├── BrewIQTests/                  # Unit tests
└── BrewIQUITests/                # UI tests
```

## Supported Brew Methods

The app includes 12 pre-configured brewing methods (select up to 9 to display):
- Pour Over (default: 17/16/15)
- French Press (default: 17/15/13)
- AeroPress (default: 15/13/11)
- Hario V60 (default: 17/16/15)
- Chemex (default: 17/16/15)
- Kalita Wave (default: 17/16/15)
- Clever Dripper (default: 17/16/15)
- Siphon Coffee (default: 17/16/14)
- Vacuum Coffee (default: 17/15.5/14)
- Moka Pot (default: 12/10/8)
- Drip Coffee (default: 17/16/15)
- Percolation (default: 18/16/14)

Each method has:
- Default coffee-to-water ratios (mild/medium/bold)
- Customizable ratios that can be reset to defaults
- Custom icon

**Custom Methods**: Users can add their own brew methods with:
- Custom name (up to 15 characters)
- Custom icon selection
- Custom mild/medium/bold ratios

## Quick Commands

### Open in Xcode
```warp-runnable-command
open BrewIQ.xcodeproj
```

### Build the project
```warp-runnable-command
xcodebuild -project BrewIQ.xcodeproj -scheme BrewIQ -configuration Debug build
```

### Run tests
```warp-runnable-command
xcodebuild test -project BrewIQ.xcodeproj -scheme BrewIQ -destination 'platform=iOS Simulator,name=iPhone 15'
```

### View git history
```warp-runnable-command
git --no-pager log --oneline --graph --all
```

### Check project status
```warp-runnable-command
git status
```

## Features

### Brew Calculator
- Calculate coffee amount from water input (or vice versa)
- Support for both metric (ml, g) and imperial (oz) units
- Adjustable strength settings (mild, medium, bold)
- Real-time calculation updates

### Customization
- Select up to 9 brew methods to display on main screen
- Customize ratios for each brew method (mild, medium, bold)
- Reset individual methods to default ratios
- Add custom brew methods with custom names, icons, and ratios
- Delete custom brew methods

### Settings
- Measurement unit preferences
- Color theme customization
- Manage custom brew methods

## Development Notes

- Uses `@Observable` macro for modern SwiftUI state management
- SwiftData persistence for user preferences and custom methods
- Model container shared across the app
- Created on November 1, 2025

## Recent Changes

- ✅ Increased max brew methods to 9 (from 6)
- ✅ Added splash screen on app launch
- ✅ Removed logo from main view for cleaner interface
- ✅ Added customization view with method selection
- ✅ Added ratio customization for all brew methods
- ✅ Added custom brew method creation
- ✅ Updated brew method ratios (Clever Dripper, Siphon, Vacuum)
- ✅ Replaced hamburger menu with customize icon
- ✅ Removed timer functionality
- ✅ Settings view and user preferences implementation
- ✅ Basic features (calculator, brew methods)
- ✅ Initial project setup

## Author

Created by Ruben Zaldana
