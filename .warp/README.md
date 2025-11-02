# BrewIQ

A SwiftUI-based iOS coffee brewing calculator and timer app that helps coffee enthusiasts brew the perfect cup with precise measurements and timing.

## Overview

BrewIQ is an iOS application built with SwiftUI and SwiftData that provides:
- **Brew Calculator**: Calculate precise coffee-to-water ratios for various brewing methods
- **Settings**: Customize preferences including measurement units and color themes
- **Custom Brew Methods**: Save and manage your own brewing recipes

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
│       └── SettingsView.swift
├── BrewIQTests/                  # Unit tests
└── BrewIQUITests/                # UI tests
```

## Supported Brew Methods

The app includes 12 pre-configured brewing methods:
- Percolation
- French Press
- Moka Pot
- Pour Over
- Drip Coffee
- AeroPress
- Hario V60
- Chemex
- Kalita Wave
- Clever Dripper
- Siphon Coffee
- Vacuum Coffee

Each method has customized:
- Coffee-to-water ratios (by strength: mild, medium, strong)
- Custom icon

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
- Adjustable strength settings (mild, medium, strong)
- Real-time calculation updates

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

- ✅ Removed timer functionality
- ✅ Settings view and user preferences implementation
- ✅ Basic features (calculator, brew methods)
- ✅ Initial project setup

## Author

Created by Ruben Zaldana
