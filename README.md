<div align="center"> <img src="assets/banner.png" alt="Bee Beyonnd — Ayurvedic, Wellness & E-Learning Platform" width="100%"/> <br/> <br/>
🐝 Bee Beyonnd
Ayurvedic, Wellness & E-Learning Platform

Steps towards Physical and Mental Wellbeing

<br/>

Show Image Show Image Show Image Show Image Show Image Show Image Show Image

<br/>

Overview • Features • Tech Stack • Architecture • Getting Started • Build & Release • Security • Roadmap • Documentation

</div>
📖 Table of Contents
Overview
Project at a Glance
Features
Screens
Tech Stack
Architecture
Project Structure
Getting Started
Configuration
Build & Release
API Integration
Security
Testing & Quality
Roadmap
Documentation
Team & Credits
Contact
License
🌿 Overview

Bee Beyonnd is a premium holistic wellness and e-learning mobile application. It brings expert-led masterclasses in Vastu, Ayurveda, Bach Flower and DMIT, an official video portal, wellness products and four-tier VIP memberships together in one secure, elegant experience.

The app is engineered with Flutter (Dart) on a clean, layered architecture:

Riverpod 2.x for fully decentralised, cache-aware state management
GoRouter with a global authentication guard and custom page transitions
Dio with an authentication interceptor and sanitised error handling
flutter_secure_storage (Android Keystore / iOS Keychain) for token protection
A bespoke, motion-rich UI: animated splash, frosted-glass alerts, neumorphic buttons and an offline overlay

📌 Release covered by this README: v1.0.3 (Build 4) — Application ID com.metrics.bee_beeyond

📊 Project at a Glance
	
Project name	Bee Beyonnd — Ayurvedic, Wellness & E-Learning Platform
Application ID	com.metrics.bee_beeyond
Current release	1.0.3 (versionName) · Build 4 (versionCode)
Framework / language	Flutter · Dart (null-safe)
State management	Riverpod 2.x
Navigation	GoRouter (RouterNotifier guard)
Networking	Dio + AuthInterceptor (Bearer JWT)
Secure storage	flutter_secure_storage
Target platform	Android (signed .aab for Google Play, release .apk for testing)
Payments	Razorpay-ready architecture
Client	Dr. Binal Shah — Bee Beyonnd
Developed by	Metricsmart Infoline Pvt. Ltd., Mumbai
<div align="center">
48	6	4	60 s
Functional requirements	Core product modules	Membership tiers	Silent background data sync
</div>
✨ Features

Every item below is implemented in release v1.0.3.

🔐 Authentication & Identity
 Secure email / password registration and login mapped to backend APIs
 4-digit OTP verification flow
 Forgot password with automated reset-link dispatch
 Persistent sessions hydrated instantly on launch from secure storage
 Smart logout — animated "Signing out safely" dialog, full cache wipe, token deletion, redirect to login
 Real-time profile sync — edits in EditProfileScreen update the Riverpod AuthState globally, no restart needed
 Human-readable errors (for example "Invalid email or password") instead of raw HTTP codes
🧘 Workshops & Masterclasses
 High-performance list with category filtering and smart search
 Real-time digital countdown (02d : 14h : 59m : 19s) for upcoming live sessions
 Smart capacity logic — blinking Seats Left and Enrolled indicators, correct handling of zero enrolled
 Intelligent booking button — auto-disables with ✓ Booked for registered users; shows Capacity Full when sold out
 Uncropped HD thumbnails on a deep-space dark frame (
#0F0C20) with zero distortion
📺 Official Video Portal
 Videos fetched exclusively from the official @beebeyonndofficial YouTube channel
 Automated channel-ID resolution (UC…) to avoid RSS 404 errors
 SmartVideoPlayerSheet — native in-app YouTube player with full-screen landscape support
 Synchronous initialisation — no flicker, no infinite spinner
 In-playlist switching via "More from Bee Beyonnd" without closing the player
🎓 E-Learning & Courses
 Course dashboard and detail view with modules, pricing and mentor details
 Enrolled vs un-enrolled conditional UI
 Study materials and PDFs unlocked for enrolled students; locked content with call-to-action for guests
 My Joined Courses screen
💳 Cart, Checkout & Memberships
 Razorpay-ready payment architecture for workshops, courses and memberships
 Four membership tiers — Bloom, Elevate, Transform, Infinity — that unlock premium content globally
 Receipt generation and preview, plus order / transaction history
 Cart and booking state managed with StateNotifierProvider
🎨 UI / UX Engineering
 Native Flutter TextStyle typography — heavy google_fonts package removed
 Bespoke splash — hexagon honeycomb painter, 360° dual aura rings, glowing orbs (min 1400 ms, max 2600 ms safety timeout)
 AppAlertManager — floating frosted-glass toasts; standardised StatusDialog (Success / Error / Loading)
 3D neumorphic buttons with a "shining light beam" animation
 ConnectionLostOverlay — frosted glass, pulsing red badge, Lottie animation, auto-dismiss when back online
 Custom transitions: FadeScale, SlideUp, SlideRight
⚙️ Platform Services
 Global route guard (RouterNotifier) redirects to /login when authentication is lost
 AutoDataSyncService silently refreshes Banners, Courses and Workshops every 60 seconds
 skipLoadingOnRefresh: true prevents flicker and RenderBox hit-test crashes
 Null-safe JSON parsing for dynamic backend types (numbers as strings, [] vs {})
 Secure local fallback models when the backend fails during development
 Audited Android manifest (UPI, WhatsApp, YouTube deep-link queries)
📱 Screens
ID	Screen	Module	Access
SCR-01	Splash	Platform	Public
SCR-02	Onboarding	Platform	Public
SCR-03	Login	Authentication	Public
SCR-04	Register	Authentication	Public
SCR-05	OTP Verification	Authentication	Public
SCR-06	Forgot Password	Authentication	Public
SCR-07	Home (banners, highlights)	Platform	Session
SCR-08	Workshop List (search, filter)	Workshops	Session
SCR-09	Workshop Detail & Booking	Workshops	Session
SCR-10	Course Dashboard	E-Learning	Session
SCR-11	Course Detail	E-Learning	Session
SCR-12	My Joined Courses	E-Learning	Session
SCR-13	Bee Beyonnd Video Portal	Video	Session
SCR-14	Smart Video Player Sheet	Video	Session
SCR-15	Memberships (Bloom – Infinity)	Memberships	Session
SCR-16	Cart / Checkout	Commerce	Session
SCR-17	Receipts & Order History	Commerce	Session
SCR-18	Profile	Account	Session
SCR-19	Edit Profile	Account	Session

🖼️ Tip: add real device screenshots to assets/screenshots/ and show them here, for example: <img src="assets/screenshots/home.png" width="220"/>

🧰 Tech Stack
Concern	Technology	Why
Framework / language	Show Image Show Image	High-fidelity UI, single code base
State management	Riverpod 2.x (FutureProvider, StateNotifierProvider)	Decentralised, testable, built-in caching
Navigation	GoRouter + RouterNotifier	Declarative routes, global guard, custom transitions
Networking	Dio + AuthInterceptor	Interceptors, timeouts, uniform errors
Secure storage	flutter_secure_storage	Keystore / Keychain-backed encryption
Preferences	SharedPreferences	Non-sensitive UI flags only
Animation	CustomPainter, implicit animations, Lottie	Splash, glow, beam, offline overlay
Video	Native YouTube player	Official content, landscape support
Payments	Razorpay (integration-ready)	UPI, cards, netbanking
Release	Android App Bundle, R8 / ProGuard	Play Store packaging and optimisation
🏗️ Architecture

The app uses a layered, feature-oriented architecture. Dependencies point inwards only — widgets never call the network directly.

<div align="center"> <img src="assets/architecture.png" alt="Bee Beyonnd layered architecture" width="90%"/> </div>
Flutter Client
PresentationScreens, Widgets,AppAlertManager,StatusDialog
NavigationGoRouter + RouterNotifierauth guard
StateRiverpod: AuthState, Cart,FutureProviders,AutoDataSyncService
Dataremote_ds, Dio,AuthInterceptor, Failuremapping, Secure Storage
Bee Beyonnd REST API
YouTube channel / player
Razorpay - ready
Android Keystore / iOSKeychain
Session lifecycle
<div align="center"> <img src="assets/session-flow.png" alt="Session lifecycle and automatic logout" width="90%"/> </div>
Backend API
Dio + AuthInterceptor
App (Riverpod)
User
Backend API
Dio + AuthInterceptor
App (Riverpod)
User
Later, any authenticated call
Login (email, password)
1
POST login
2
Request
3
JWT + user profile
4
Success
5
Store token in secure storage
6
GET protected resource
7
Authorization: Bearer token
8
401 Unauthorized
9
Trigger secure logout
10
Wipe cache, delete token
11
Redirect to /login
12
Key components
Component	Layer	Responsibility
RouterNotifier	Navigation	Watches AuthState, redirects to /login when authentication is lost
AuthState / notifier	State	Holds user, token and status; updated live by EditProfileScreen
AutoDataSyncService	State	Refreshes Banners, Courses, Workshops every 60 s without UI flicker
AuthInterceptor	Data	Adds Bearer token; detects 401 and forces secure logout
remote_ds files	Data	Call endpoints, parse JSON, convert exceptions into Failure classes
ApiEndpoints.dart	Data	Single catalogue of all backend routes
AppAlertManager / StatusDialog	Presentation	Unified toasts and Success / Error / Loading dialogs
ConnectionLostOverlay	Presentation	Frosted-glass offline overlay with Lottie animation
SmartVideoPlayerSheet	Presentation	In-app YouTube player with playlist switching
🗂️ Project Structure

The tree below is a representative layout. Adjust folder and file names to match your repository.

text
bee_beyonnd/
├── android/
│   ├── app/
│   │   ├── build.gradle                 # versioning, signing, R8 config
│   │   └── src/main/AndroidManifest.xml # permissions, deep-link queries
│   └── key.properties                   # ⚠️ local only — NEVER commit
├── assets/
│   ├── lottie/                          # offline overlay and other animations
│   └── images/
├── docs/
│   └── Bee_Beyonnd_SRS_and_Project_Report.pdf
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── network/                     # dio client, auth_interceptor, api_endpoints.dart
│   │   ├── router/                      # app_router, router_notifier, transitions
│   │   ├── errors/                      # Failure classes
│   │   ├── storage/                     # secure storage + shared preferences wrappers
│   │   └── widgets/                     # app_alert_manager, status_dialog, connection_lost_overlay
│   ├── features/
│   │   ├── auth/                        # login, register, otp, forgot password, profile
│   │   ├── workshops/                   # list, detail, countdown, booking button
│   │   ├── videos/                      # video portal, smart_video_player_sheet
│   │   ├── courses/                     # dashboard, detail, my joined courses
│   │   ├── memberships/                 # Bloom, Elevate, Transform, Infinity
│   │   └── checkout/                    # cart, receipts, order history
│   └── services/
│       └── auto_data_sync_service.dart
├── test/
└── pubspec.yaml
🚀 Getting Started
Prerequisites
Tool	Notes
Flutter SDK	Stable channel, compatible with the SDK constraint in pubspec.yaml
Dart SDK	Bundled with Flutter
Android Studio or VS Code	With Flutter and Dart plugins
JDK 17	Required by recent Android Gradle Plugin versions
Android device / emulator	Android API level as defined in android/app/build.gradle
Installation
bash
# 1. Clone the repository
git clone https://github.com/<your-org>/<your-repo>.git
cd <your-repo>

# 2. Verify your environment
flutter doctor

# 3. Install dependencies
flutter pub get

# 4. Run the app on a connected device or emulator
flutter run
⚙️ Configuration
1. API base URL

All backend routes live in a single catalogue, ApiEndpoints.dart. Point the base URL to your API host:

dart
class ApiEndpoints {
  static const String baseUrl = 'https://<your-api-host>/api';
  // ... individual endpoints are defined below
}
2. Release signing

Create android/key.properties locally (never commit it):

properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=<absolute-path-to>/upload-keystore.jks

Make sure your .gitignore contains:

gitignore
# Signing secrets — never commit
android/key.properties
*.jks
*.keystore

⚠️ Back up the upload keystore in a secure vault. Losing it blocks future updates.

3. Payments (Razorpay)

The checkout layer is Razorpay-ready. To go live, add the production key through your secure configuration (not in source control) and verify payment callbacks on the backend.

📦 Build & Release
Build commands
bash
# Static analysis and tests
flutter analyze
flutter test

# Play Store bundle (required by Google Play)
flutter build appbundle --release

# Release APK for direct installation / internal testing
flutter build apk --release

# Recommended: obfuscated build for the final store release
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols

Output files:

Artifact	Path
App Bundle	build/app/outputs/bundle/release/app-release.aab
APK	build/app/outputs/flutter-apk/app-release.apk
Versioning policy

The project follows Semantic Versioning 2.0.0 with an incrementing build number, defined in pubspec.yaml:

yaml
version: 1.0.3+4   # versionName 1.0.3, versionCode 4
Change type	Bump	Example
Backward-compatible bug fix, UI polish	PATCH	1.0.3 → 1.0.4
New backward-compatible feature	MINOR	1.0.3 → 1.1.0
Breaking change / major redesign	MAJOR	1.x → 2.0.0
Every new Play Store upload	Build number +1	+4 → +5
Release history
Version	Build	Track / type	Notes	Status
1.0.1	2	Closed testing (Alpha)	Pre-release build for testers	Superseded
1.0.2	3	Internal build	Stabilisation and refinement	Superseded
1.0.3	4	Production-ready	Complete feature set; signed AAB and APK	Current
Google Play testing tracks
Track	Purpose	Audience
Internal testing	Fast smoke test of each new build	Up to 100 testers by email
Closed testing (Alpha)	Structured pre-production testing	Invited testers (email lists / groups)
Open testing	Public beta (optional)	Anyone with the link
Production	General availability	All eligible users

ℹ️ Personal developer accounts created after 13 November 2023 must complete a closed test with a minimum number of opted-in testers for 14 continuous days before applying for production. Verify the current rule in Play Console.

Pre-release checklist
 versionName and versionCode increased and verified in the built bundle
 flutter analyze and flutter test pass
 Bundle signed with the upload key
 Smoke test on a physical device from the internal track
 Store listing, App content and Data safety sections complete and accurate
 Privacy policy URL live; reviewer test credentials supplied in App access
 Rollback plan agreed (halt rollout, release previous stable with a higher build number)
🔌 API Integration
Protocol: REST over HTTPS, JSON payloads
Authentication: JWT in the Authorization: Bearer <token> header, injected by AuthInterceptor
Endpoint catalogue: ApiEndpoints.dart
Caching: FutureProvider caches + silent 60 s refresh using skipLoadingOnRefresh: true
API group	Operations	Used by
Authentication	Register, login, OTP verify, forgot password, logout	SCR-03 – SCR-06
Profile	Fetch and update profile	SCR-18, SCR-19
Banners & Home	Banners and highlights	SCR-07
Workshops	List, detail, seats, enrolled count, booking	SCR-08, SCR-09
Courses	List, detail, materials, joined courses	SCR-10 – SCR-12
Memberships	Plans, active membership, entitlements	SCR-15
Orders & Receipts	Create order, history, receipt data	SCR-16, SCR-17
Error handling
Condition	Application behaviour
401 Unauthorized	Immediate secure logout, cache wipe, redirect to /login
422 validation error	Friendly message, e.g. "Invalid email or password"
Timeout / slow network	Readable retry message; UI stays responsive
No connectivity	ConnectionLostOverlay; auto-dismisses on reconnect
5xx server error	Generic, non-technical message with retry
Malformed JSON	Safe defaults or local fallback model — no crash
YouTube integration
Start from the official handle @beebeyonndofficial
Resolve the dynamic channel ID (UC…) — no hard-coded or stale IDs
Request the channel RSS feed with the resolved ID (prevents 404s)
Map feed entries to video models (id, title, thumbnail, date)
Play inside SmartVideoPlayerSheet with in-playlist switching
🔒 Security
Area	Control
Credential storage	JWT stored via flutter_secure_storage (Android Keystore / iOS Keychain)
Preference hygiene	SharedPreferences only for non-sensitive flags (theme, onboarding)
API authentication	Global AuthInterceptor injects the Bearer token
Session integrity	401 → forced logout, token deletion, cache wipe
Route protection	RouterNotifier redirects unauthenticated access to /login
Error hygiene	Raw HTTP / parsing details never shown to the user
Transport	HTTPS only
Manifest	Least-privilege permissions; package queries only for UPI, WhatsApp, YouTube

Recommended hardening for the final store release

 Enable R8 / ProGuard (isMinifyEnabled = true) and Flutter obfuscation after regression testing
 Enrol in Play App Signing and keep the upload keystore backed up
 Consider certificate pinning and root / emulator detection for payment flows
 Keep the Data safety form and privacy policy in sync with real app behaviour

🛡️ Never commit keystores, key.properties, API secrets or payment keys to the repository.

🧪 Testing & Quality
bash
flutter analyze   # static analysis
flutter test      # unit and widget tests
Level	Scope
Static analysis	Whole code base, null-safety, lints
Unit tests	Parsers, Failure mapping, providers
Widget tests	Key screens and component states
Device testing	End-to-end flows on real devices (low / mid / high-end, tablet)
UAT	35 test cases (TC-01 – TC-35) documented in the SRS

Definition of Done

 Requirement implemented and traceable to an ID
 Null-safe, no analyzer errors
 Loading, empty, error and success states handled
 Navigation and session-expiry behaviour verified
 No sensitive data in insecure storage or logs
 Release build compiles, signs and launches
🗺️ Roadmap

Proposed scope — subject to client approval.

 1.0.x — Core modules: authentication, workshops, video portal, courses, memberships, secure networking
 1.1.0 — Razorpay production go-live, verified payment callbacks, receipts from payment IDs, billing-policy review
 1.2.0 — Push notifications for workshop reminders, deep-link sharing
 1.3.0 — Learning progress tracking, bookmarks, certificates of completion
 1.4.0 — Regional language support (e.g. Hindi, Gujarati) and accessibility enhancements
 1.5.0 — iOS release from the existing Flutter code base
 2.0.0 — Community features, personalised recommendations, analytics dashboard
📚 Documentation
Document	Description
📄 SRS & Project Report (PDF)	Complete requirements, architecture, security, release, testing, traceability and acceptance certificate (39 pages)

The report includes requirement tables with Built and Client Verified checkboxes, a 35-case UAT catalogue, a traceability matrix, risk register, hand-over checklist and the client acceptance certificate.

👥 Team & Credits
<div align="center"> <img src="assets/metriics-logo.png" alt="Metricsmart Infoline Pvt. Ltd." width="240"/>

Developed and delivered by Metricsmart Infoline Pvt. Ltd.

</div>
Name	Department	Responsibility
ER. Harsh Mishra	Mobile App Development Department	Flutter architecture, UI/UX, state management, navigation, builds and release
ER. Ambrish Dubey	Department of Backend Development	REST API, authentication, data models, server security and deployment

Client: Dr. Binal Shah — Bee Beyonnd

📬 Contact
Metricsmart Infoline Pvt. Ltd. (Developer)

📍 Riddhi Siddhi Complex, E-107, Swami Vivekanand Rd, opposite Patkar College, Unnat Nagar, Goregaon West, Mumbai, Maharashtra 400104 📞 098671 99213 ✉️ info@metricsmartinfoline.in

Bee Beyonnd (Client)

📍 Mumbai: Dotom Isle, Jankalyan Nagar, Malad West, Mumbai, Maharashtra – 400095 📍 Surat: 134, Unicorn Plaza, 1st Floor, Vesu, Opp. Swastik Woods, Surat, Gujarat – 395007 📞 +91 99673 26151 · +91 88509 26497 / +91 98927 11391 ✉️ Beebeyonnd5@gmail.com ▶️ YouTube: @beebeyonndofficial

📄 License

Proprietary — All rights reserved. © 2026 Metricsmart Infoline Pvt. Ltd. and Bee Beyonnd. Unauthorised copying, distribution or modification of this software, in whole or in part, is strictly prohibited without prior written permission.

<div align="center"> <img src="assets/logo.png" alt="Bee Beyonnd" width="70"/>

Bee Beyonnd — Steps towards Physical and Mental Wellbeing

Built with 💜 using Flutter by Metricsmart Infoline Pvt. Ltd.

</div>
