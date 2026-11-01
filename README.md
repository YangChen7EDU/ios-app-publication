# ios-app-publication

Research on the rules, process and review requirements for publishing iOS apps on the App Store, using **7EDU shipping 7edu.vip (Seven by 7EDU) as an iOS app** as the main case.

> Last updated 2026-11-01. Apple changes these rules every year, usually after WWDC in June and again after the new OS ships in September–November. Before submitting, check the original text in [Official references](#6-official-references).

---

## 0. Overview

| Stage | What to do | One-time / every release |
|---|---|---|
| Account | Apple Developer Program enrolled as an Organization under 7EDU | One-time |
| Compliance design | Sign in with Apple, account deletion, third-party AI disclosure, privacy for minors | One-time (recheck when it changes) |
| App Store Connect setup | Bundle ID, app name, privacy policy, privacy label, age rating, agreements and tax | One-time |
| Build and upload | Bump version → Archive → upload | **Every release** |
| Testing | TestFlight, internal and external | **Every release** |
| Submit for review | What's New, screenshots (only if the UI changed), review notes | **Every release** |
| Release | Manual, automatic, or phased release | **Every release** |

---

## 1. 7edu.vip and what it means for App Review

7edu.vip is a Next.js 15 + Supabase web app deployed on Vercel. The product is Seven ("Seven by 7EDU"), built for **parents (mostly of 9th–10th graders)** and **students themselves**. It is free, and its core is chatting with Seven and generating a college plan.

These facts decide what App Review will look at most closely:

| Fact about 7edu.vip | App Store rule | What we need to do |
|---|---|---|
| Today it is only a website | **4.2 Minimum Functionality**: a website wrapped in an app gets rejected | The app must offer things the website can't (see 2.2) |
| Google sign-in (Supabase OAuth) | **4.8 Login Services**: if you offer a third-party login, you must also offer a privacy-focused login option. In practice, that means Sign in with Apple | Enable the Apple provider in Supabase and add a Sign in with Apple button in the app |
| Users can create accounts | **5.1.1(v)**: if users can sign up in the app, they must be able to delete their account in the app | Add "Delete account" in Settings that actually deletes the data, not just deactivates it |
| Chat and plans send student data to OpenAI / Anthropic / Google models | **5.1.2(i)** (revised Nov 2025): before sending personal data to a third-party AI, clearly disclose it and get the user's explicit permission | Show a consent screen before the first use of Seven that says what is sent and to whom; say the same in the privacy policy |
| Some users are minors | **5.1.4 Kids**, COPPA, the age rating questionnaire | Don't pick the Kids category (it adds restrictions). Use Education. Answer the age rating honestly (with AI chat, expect around 13+). Don't open student sign-up to under-13s, or add a parental consent flow |
| User-generated content and chat | **1.2 User-Generated Content** | Provide reporting and blocking, and describe how AI output is filtered |
| May charge later (human counseling) | **3.1.1 In-App Purchase** / **3.1.3(d) Person-to-Person Services** | For v1, sell nothing in the app. That is the simplest path. Research this separately before adding payments |
| The website avoids words like "AI" and "app" (PRODUCT.md) | App Store metadata | Keep the brand wording in the name and subtitle, e.g. "Seven by 7EDU". Names must be unique across the store, max 30 characters. Reserve it early |

---

## 2. First release: full checklist

### 2.1 Account (do this first; it can take 1–2 weeks)

- [ ] **Enroll as an Organization under 7EDU.** That way the store shows 7EDU as the developer and seller.
  - If your existing developer account is an **Individual** account, the App Store shows your personal name. Use it for practice apps, not for the company product.
  - An Organization account needs a legal entity, a **D-U-N-S number** (free; a few business days to two weeks), a company-domain email, and someone with signing authority. The fee is $99/year.
  - You can transfer an app from an individual account to the company account later (App Transfer), but it has limits. It is easier to use the right account from the start.
- [ ] Invite the team in App Store Connect and assign roles (Admin / App Manager / Developer / Marketing).
- [ ] Sign the **Paid Apps agreement** and fill in tax and banking info. Worth doing even for a free app, because in-app purchases need it later.
- [ ] To ship in the EU: provide **DSA trader information** (the company address, phone and email are shown publicly). Skip this if you aren't shipping in the EU.
- [ ] To ship on the China mainland storefront: you need an **ICP filing number**, and generative AI features need separate approval there. **Leave China mainland out of v1.**

### 2.2 Technical approach (decides whether you pass 4.2)

| Approach | Good for | 4.2 risk |
|---|---|---|
| Plain WKWebView loading 7edu.vip | Not recommended | **Very high**, almost certain rejection |
| **Capacitor** wrapper plus real native features (push, Sign in with Apple, share, native navigation) | Reusing as much of the Next.js code as possible | Medium; the native features must be real |
| **Expo / React Native** with a new mobile UI, reusing Supabase and the API | A native feel, for a team that knows React | Low |
| Native SwiftUI | Best experience, highest cost | Low |

Whatever the approach, give at least 2–3 things the website can't do, such as:
- **Push notifications**: new plan milestones from Seven, meeting reminders, deadline reminders
- Native sign-in (Sign in with Apple, Face ID for quick login)
- Offline viewing of the plan / Timeline
- Sharing to Messages or WeChat, home screen widgets

Also keep in mind:
- Serving core features from a remote web page lets you change what the app does without review, which breaks **2.5.2 / 4.7**. Bug fixes are fine; changing the app's purpose is not.
- Tooling: since **2026-04-28**, uploaded builds must be made with **Xcode 26 and the iOS 26 SDK**.

### 2.3 Project setup (one-time)

- [ ] **Bundle ID**: e.g. `vip.7edu.seven`. It can't be changed once the app exists.
- [ ] Capabilities: Sign in with Apple, Push Notifications, Associated Domains (`applinks:7edu.vip`, so links in emails open the app).
- [ ] **Supabase**: enable the Apple provider, and add the app's callback scheme or universal link to Redirect URLs.
- [ ] **Privacy manifest `PrivacyInfo.xcprivacy`**: declare the data types collected and any Required Reason APIs used (e.g. UserDefaults, file timestamps). Third-party SDKs must ship their own manifests too.
- [ ] Info.plist:
  - `ITSAppUsesNonExemptEncryption = NO` (if you only use HTTPS, this skips the export compliance question after every upload)
  - A purpose string for every permission used, e.g. `NSCameraUsageDescription` (when uploading a photo of a transcript)
- [ ] App icon: 1024×1024, opaque, no rounded corners.
- [ ] Signing: Xcode Automatic Signing is enough. For push, create an APNs key (.p8) in the developer portal and give it to the backend.

### 2.4 App Store Connect setup (one-time)

- [ ] Create the app: name, primary language (English (U.S.)), Bundle ID, SKU.
- [ ] **Privacy policy URL** (required), e.g. `https://7edu.vip/privacy`. It must cover:
  - what data is collected
  - which third parties receive it, **including which AI providers**
  - how long data is kept
  - how to delete it
  - how data from minors is handled
- [ ] **Support URL** (required), e.g. `https://7edu.vip/support`.
- [ ] **App privacy label (privacy nutrition label)**: honestly declare the data collected, such as contact info, user content (chat, academic records), identifiers, and usage data, and for each one whether it is linked to the user's identity and whether it is used for tracking. **The label, the privacy manifest and the privacy policy must all agree.** Mismatches are a common rejection reason.
- [ ] **Age rating questionnaire**: since 2025 the ratings are 4+ / 9+ / 13+ / 16+ / 18+. Answer the questions about unrestricted web access, user-generated content and chat/messaging honestly.
- [ ] Category: primary Education, secondary Productivity.
- [ ] Price: free. Availability: start with the United States (Canada and others optional).
- [ ] Store listing metadata:
  - Name (30 characters) and subtitle (30 characters)
  - Description (no pricing changes, no mentions of other platforms)
  - Keywords (100 characters, comma-separated, don't repeat words from the name, no competitor names)
  - Screenshots
  - Promotional text (can change anytime without review)
- [ ] **Screenshots**: at least one set of 6.9" iPhone screenshots (1320×2868 or 1290×2796, portrait), up to 10. If the app runs on iPad, also 13" iPad screenshots (2064×2752). Screenshots must show the real app UI.

### 2.5 App Review Information

This step decides whether you pass on the first try:

- [ ] **Provide demo accounts**: at least one parent account that already has a student with a generated plan, so the reviewer can see the core features without going through onboarding. Add a student account if needed. The accounts must not expire during review and must not require two-factor authentication.
- [ ] In the notes, explain in English:
  - what the app does
  - where it calls third-party AI, and where the consent screen is
  - where account deletion is (give the exact path, e.g. Settings → Account → Delete Account)
  - what push notifications are used for
- [ ] Contact: phone and email. The reviewer may call.

### 2.6 Self-check before the first submission

- [ ] On a real device, starting from a **fresh install**: sign up → Sign in with Apple → AI consent screen → generate a plan → delete the account
- [ ] No blank screens or crashes when offline or on a weak network
- [ ] No "Beta", "Coming soon", placeholder text, empty pages or dead links
- [ ] No links sending users to pay on the website (unless you've researched 3.1 and the US storefront rules for external links)
- [ ] Every permission prompt appears when the feature is first used, not all at once on launch
- [ ] Run one round of internal TestFlight first

---

## 3. Every new version: standard process

| Step | What to do | Notes |
|---|---|---|
| 1. Bump versions | `Version` (CFBundleShortVersionString, e.g. 1.2.0) is what users see; `Build` (CFBundleVersion) **must increase on every upload** | One Version can have several Builds |
| 2. Build and upload | Xcode → Product → Archive → Distribute App → App Store Connect; or `xcodebuild` / fastlane / Xcode Cloud / EAS | Processing in App Store Connect usually takes 5–30 minutes |
| 3. TestFlight | Internal testers (up to 100 team members) **need no review**; external testers (up to 10,000) need Beta App Review for the first build | Each build expires after 90 days |
| 4. Create the version | App Store Connect → "+ Version" → write **What's New**, pick the Build | |
| 5. Recheck metadata | Update screenshots if the UI changed noticeably; if you collect new data, **update the privacy label and privacy policy**; if there is a new kind of content, retake the age rating questionnaire | Forgetting the privacy label is a common rejection reason |
| 6. Submit for review | In the review notes, explain what changed, especially new features and permissions | Most reviews finish within 24–48 hours |
| 7. Release | Manual, automatic after approval, or **phased release** (over 7 days, 1% → 2% → 5% → 10% → 20% → 50% → 100% of users with automatic updates on; can be paused) | Use phased release for major versions |
| 8. After release | Watch crashes in Xcode Organizer or App Store Connect, read reviews, ship a fix fast if needed | |

**Urgent fixes**: request an **Expedited Review** in App Store Connect. Use it only for critical bugs or security issues, and not often.

**Changes that don't need a new version**: promotional text, the backend API, web content (as long as it doesn't change what the app is or does).

**Changes that need a new version**: native code, permissions, new SDKs, the privacy manifest.

**If you're rejected**: reply in the Resolution Center in App Store Connect.
- If it's a misunderstanding: explain, or add screenshots or a video.
- If it's a real violation: fix it and resubmit.
- If you disagree with the decision: appeal to the App Review Board.

---

## 4. Most likely rejection reasons for 7edu.vip (by risk)

1. **4.2 Minimum Functionality**: looks like the website in a wrapper. → Add push, native sign-in, native navigation; don't open straight into a web page.
2. **4.8 / Sign in with Apple**: Google sign-in without Apple sign-in.
3. **5.1.1(v) Account deletion**: no delete option, or deletion means "contact support".
4. **5.1.2(i) Third-party AI**: sending student data to a model without clearly disclosing it and getting consent in the app.
5. **2.1 Incomplete information**: the demo account is empty, can't log in, or needs an SMS code.
6. **5.1.1 Privacy consistency**: the privacy label, privacy manifest and privacy policy don't match.
7. **1.2 / Age rating**: open AI chat with minor users, and an age rating set too low.

---

## 5. Practice plan (a few small apps on the personal account first)

1. **App A: minimal native app** (SwiftUI, one screen) → run the whole flow: Archive, upload, TestFlight, submit, release.
2. **App B: app with sign-in** → practice Sign in with Apple, account deletion, the privacy label.
3. **App C: a small Next.js project wrapped with Capacitor or Expo, with push** → test where the 4.2 line is. This is closest to 7edu.vip.
4. Every time an app is rejected, log the reason and the fix in the review log below.

### Review log

| Date | App | Version | Result | Guideline | Reason / fix |
|---|---|---|---|---|---|
| | | | | | |

---

## 6. Official references

- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/): source of every guideline number (4.2, 4.8, 5.1.x, etc.)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [SDK minimum requirements](https://developer.apple.com/news/upcoming-requirements/): minimum Xcode and SDK versions
- [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/)
- [App privacy details](https://developer.apple.com/app-store/app-privacy-details/): the privacy label
- [Privacy manifest files](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files)
- [Offering account deletion in your app](https://developer.apple.com/support/offering-account-deletion-in-your-app/)
- [Sign in with Apple](https://developer.apple.com/sign-in-with-apple/)
- [Enrolling as an organization / D-U-N-S](https://developer.apple.com/help/account/membership/D-U-N-S/)
- [TestFlight](https://developer.apple.com/testflight/)
- [Phased release](https://developer.apple.com/help/app-store-connect/update-your-app/release-a-version-update-in-phases/)
