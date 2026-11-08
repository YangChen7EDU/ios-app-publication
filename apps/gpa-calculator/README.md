# GPA Calculator

Practice app #1 (App A in the [practice plan](../../README.md#5-practice-plan-a-few-small-apps-on-the-personal-account-first)). A small native SwiftUI app for high school students to track weighted and unweighted GPA by term. The goal is to run the full App Store flow once — archive, upload, TestFlight, review, release — with an app that has nothing hard to review: no login, no network, no data collected.

- Account: personal developer account
- Bundle ID: `com.andychen.gpacalculator` (change it in `project.yml` before creating the app in App Store Connect; it can't be changed afterwards)
- Minimum iOS: 17.0, iPhone only
- Version: 1.0.0 (1)

## What it does

- Terms (e.g. "9th Grade · Fall"), each with courses: name, letter grade, level (Regular / Honors / AP / IB), credits
- Term GPA and cumulative GPA, both weighted and unweighted, averaged by credits
- Honors adds 0.5, AP / IB adds 1.0 to the weighted GPA, never for an F
- Setting for A+ = 4.0 or 4.3
- Data is stored on the device with SwiftData; "Delete All Data" in Settings

Enough real function for **4.2 Minimum Functionality**. The risk to watch is **4.3 Spam** (there are many GPA calculators): the term-by-term history, weighted/unweighted side by side and a careful store listing are what set it apart.

## Develop

Requires Xcode and [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`). The `.xcodeproj` is generated and not committed.

```bash
xcodegen generate
open GPACalculator.xcodeproj
```

Run the unit tests from the command line:

```bash
xcodebuild test -project GPACalculator.xcodeproj -scheme GPACalculator -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

Layout:

```
project.yml                   # XcodeGen spec: targets, versions, Info.plist keys
GPACalculator/
  GPACalculatorApp.swift      # entry point, SwiftData container
  Models/GPA.swift            # grades, levels, GPA math (pure, unit tested)
  Models/Term.swift           # SwiftData models: Term, Course
  Views/                      # SwiftUI screens
  Assets.xcassets             # AppIcon (1024×1024), AccentColor
  PrivacyInfo.xcprivacy       # privacy manifest
GPACalculatorTests/           # GPA math tests
store/                        # App Store listing text and review notes
PRIVACY.md                    # privacy policy, linked from App Store Connect
```

## Before the first upload

- [ ] Upgrade to **Xcode 26**. Builds made with Xcode 16 are rejected at upload since 2026-04-28 ([SDK minimum requirements](https://developer.apple.com/news/upcoming-requirements/)).
- [ ] Set `DEVELOPMENT_TEAM` in `project.yml` to your Team ID (Xcode → Settings → Accounts), and confirm the Bundle ID.
- [ ] Register the Bundle ID in the developer portal, or let Xcode do it with Automatic Signing.
- [ ] Pick an available app name (see `store/listing.md`) and create the app in App Store Connect.
- [ ] Take screenshots on the iPhone 16 Pro Max / 17 Pro Max simulator (6.9") with sample data.
- [ ] Archive (Product → Archive, scheme GPACalculator, destination Any iOS Device) → Distribute App → App Store Connect.
- [ ] Install from TestFlight on a real phone and run through: add term → add courses → edit → delete → settings → delete all.

## App Store Connect answers

| Field | Answer | Why |
|---|---|---|
| App Privacy | **Data Not Collected** | Nothing leaves the device; no analytics or SDKs |
| Privacy policy URL | `https://github.com/YangChen7EDU/ios-app-publication/blob/main/apps/gpa-calculator/PRIVACY.md` | Required for every app, even with no data collected |
| Support URL | `https://github.com/YangChen7EDU/ios-app-publication/issues` | |
| Age rating | All answers "None" / "No" → **4+** | No user-generated content, no web access, no chat |
| Category | Education (secondary: Productivity) | |
| Price | Free | |
| Encryption | Uses no non-exempt encryption (`ITSAppUsesNonExemptEncryption = NO` is set) | |
| Sign-in required | No | No demo account needed |

## Release history

| Version | Build | Date | Result | Notes |
|---|---|---|---|---|
| 1.0.0 | 1 | | | First submission |
