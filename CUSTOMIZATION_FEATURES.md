# Customization Features Implementation

## Overview
This document describes the customization features added to BrewIQ, allowing users to personalize their brewing experience.

## Features Implemented

### 1. Method Selection (Max 6)
- Users can select up to 6 brew methods to display on the main calculator screen
- By default, the first 6 methods are selected: Pour Over, French Press, AeroPress, Hario V60, Chemex, Kalita Wave
- Selection is managed through the CustomizationView

### 2. Updated Brew Method Ratios
All brew methods now have corrected ratios (Mild/Medium/Bold):

| Method | Mild | Medium | Bold |
|--------|------|--------|------|
| Pour Over | 1:17 | 1:16 | 1:15 |
| French Press | 1:17 | 1:15 | 1:13 |
| AeroPress | 1:15 | 1:13 | 1:11 |
| Hario V60 | 1:17 | 1:16 | 1:15 |
| Chemex | 1:17 | 1:16 | 1:15 |
| Kalita Wave | 1:17 | 1:16 | 1:15 |
| Clever Dripper | 1:17 | 1:16 | 1:15 |
| Siphon Coffee | 1:17 | 1:16 | 1:14 |
| Vacuum Coffee | 1:17 | 1:15.5 | 1:14 |
| Moka Pot | 1:12 | 1:10 | 1:8 |
| Drip Coffee | 1:17 | 1:16 | 1:15 |
| Percolation | 1:18 | 1:16 | 1:14 |

### 3. Ratio Customization
- Users can customize the mild, medium, and bold ratios for any brew method
- Custom ratios are stored per-method in UserPreferences
- Each method shows its default ratios and allows editing
- **Reset to Default**: Users can reset any method back to its default ratios

### 4. Custom Brew Methods
Users can create their own brew methods with:
- **Custom Name**: Up to 15 characters (to fit in the button)
- **Custom Icon**: Choose from 8 available SF Symbols
- **Custom Ratios**: Set mild, medium, and bold ratios
- **Delete**: Swipe to delete custom methods

Available icons for custom methods:
- mug.fill
- cup.and.saucer.fill
- drop.fill
- sparkles
- star.fill
- heart.fill
- leaf.fill
- flame.fill

### 5. UI Changes
- **Replaced hamburger menu** (line.3.horizontal) with **customize icon** (slider.horizontal.3)
- The customize button is in the top-right corner of the main screen
- Opens CustomizationView as a sheet

## File Structure

### New Files
- `BrewIQ/Views/CustomizationView.swift` - Main customization interface with:
  - Method selection (max 6)
  - Ratio editing
  - Custom method creation

### Modified Files
- `BrewIQ/Models/BrewMethod.swift` - Updated ratios and reordered methods
- `BrewIQ/Views/BrewCalculatorView.swift` - Changed settings to customization
- `BrewIQ/ViewModels/BrewCalculatorViewModel.swift` - Removed timer reference
- `.warp/README.md` - Updated documentation

### Removed Files
- `BrewIQ/Views/SettingsView.swift` - Replaced by CustomizationView.swift

### Existing Files (Already Present)
- `BrewIQ/Models/UserPreferences.swift` - Already had customization support
- `BrewIQ/Models/CustomBrewMethod.swift` - Already existed for SwiftData

## User Workflow

1. **Select Methods**:
   - Tap customize icon (top-right)
   - See all 12 brew methods
   - Tap to select/deselect (max 6)
   - Selected methods show checkmark

2. **Customize Ratios**:
   - In "Customize Ratios" section
   - Tap any selected method
   - See default ratios
   - Edit mild, medium, bold values
   - Save or Reset to Default

3. **Add Custom Method**:
   - Tap "Add Custom Method"
   - Enter name (max 15 chars)
   - Choose icon
   - Set ratios
   - Tap Add

4. **Delete Custom Method**:
   - Swipe left on custom method
   - Tap Delete

5. **Save Changes**:
   - Tap "Save" in navigation bar
   - Changes persist with SwiftData

## Data Persistence

All customization data is stored in `UserPreferences` (SwiftData):
- `selectedMethodRawValues: [String]` - Selected method IDs
- `customRatios: [String: CustomRatio]` - Per-method custom ratios
- `customMethods: [CustomBrewMethodData]` - User-created methods

## Notes

- The app defaults to showing the first 6 methods if no preferences exist
- Custom ratios take precedence over default ratios
- Hario V60, Chemex, and Kalita Wave all use the same ratios as Pour Over
- Method order in the enum prioritizes most popular methods first
