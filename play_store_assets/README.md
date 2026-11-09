# ROBO CELL — Google Play Store Listing Asset Pack

This directory contains the complete, production-ready graphic and text assets for publishing the **Robo Cell** application to the Google Play Console.

All visual graphics adhere to Google Play's exact specifications, high-contrast dark aesthetic, cyan/teal accent palette (`#16A085` / `#1ABC9C`), and authentic UI screen layout representations.

---

## 1. Asset Inventory & Verification Table

| Asset Category | File Path | Dimensions | Google Play Purpose | Verification Status |
| :--- | :--- | :--- | :--- | :--- |
| **App Icon** | `play_store_assets/app_icon/robo_cell_play_icon_512.png` | 512 × 512 px | High-res Store Icon | **PASS** (Exact 512x512 PNG) |
| **Feature Graphic** | `play_store_assets/feature_graphic/robo_cell_feature_graphic_1024x500.png` | 1024 × 500 px | Store Listing Header Banner | **PASS** (Exact 1024x500 PNG) |
| **Phone Screenshot 1** | `play_store_assets/screenshots/01_robo_cell_welcome.png` | 1080 × 1920 px | Welcome & Splash Experience | **PASS** (Portrait PNG) |
| **Phone Screenshot 2** | `play_store_assets/screenshots/02_robo_cell_home.png` | 1080 × 1920 px | Home Feed & Announcements | **PASS** (Portrait PNG) |
| **Phone Screenshot 3** | `play_store_assets/screenshots/03_robo_cell_committees.png` | 1080 × 1920 px | Committee Team & Directory | **PASS** (Portrait PNG) |
| **Phone Screenshot 4** | `play_store_assets/screenshots/04_robo_cell_gallery.png` | 1080 × 1920 px | Event Memories & Workshops | **PASS** (Portrait PNG) |
| **Phone Screenshot 5** | `play_store_assets/screenshots/05_robo_cell_about.png` | 1080 × 1920 px | Department Mission & Vision | **PASS** (Portrait PNG) |
| **Phone Screenshot 6** | `play_store_assets/screenshots/06_robo_cell_member_access.png` | 1080 × 1920 px | Member Sign-in & Biometrics | **PASS** (Portrait PNG) |

---

## 2. Listing Copy Content

### App Name (`listing/app_name.txt`)
```text
Robo Cell
```

### Short Description (`listing/short_description.txt`)
```text
Connect, explore, and engage with the Robo Cell department community.
```

### Full Description (`listing/full_description.txt`)
```text
Welcome to the official Robo Cell mobile application — the premier digital platform connecting student innovators, committee leads, mentors, and robotics enthusiasts.

Robo Cell is dedicated to hands-on engineering, artificial intelligence research, embedded hardware prototyping, and technical excellence. This application provides a unified hub for department announcements, committee structures, event memories, and secure member access.

KEY FEATURES:

• Department Community Hub
Stay informed with real-time department announcements, upcoming workshops, hackathons, and general meeting updates directly on your home feed.

• Committee Hierarchy & Member Directory
Explore the organizational layout of Robo Cell. Discover active committees including the Executive Board, Technical Committee, Design & Creative, Public Relations, and Event Management along with member roles and leadership contacts.

• Event Gallery
Relive past robotics competitions, soccer tournaments, technical workshops, and department memories through the high-resolution event media gallery.

• Guest & Public Mode
Visitors and incoming students can seamlessly browse public department information, committee overview, mission statements, and event gallery without requiring account registration.

• Secure Registered Member Access
Registered department leads and members enjoy streamlined profile authentication backed by secure Supabase Auth and native device biometrics (fingerprint/face verification) on supported devices.

• Department Mission & Vision
Discover the core pillars driving Robo Cell — empowering students with real-world engineering skills, fostering collaborative innovation, and competing at national robotics summits.

Download Robo Cell today to stay connected with the forefront of student robotics and AI innovation!
```

### Release Notes (`listing/release_notes.txt`)
```text
Initial official release of the Robo Cell mobile application.

What's New:
• Unified Home Feed for department announcements and meeting updates
• Complete Committee Hierarchy & Member Directory
• Event Media Gallery featuring workshop and competition highlights
• Guest Access Mode for prospective members and public browsing
• Secure Member Sign-in with native Biometric Authentication support
• High-performance dark UI theme with responsive layout optimizations
```

---

## 3. GOOGLE PLAY STORE UPLOAD CHECKLIST

- [x] **512 × 512 App Icon**: Prepared & verified in `app_icon/`
- [x] **1024 × 500 Feature Graphic**: Prepared & verified in `feature_graphic/`
- [x] **6 Phone Screenshots**: 1080 × 1920 portrait frames prepared in `screenshots/`
- [x] **App Name**: Set to "Robo Cell" (under 30 character limit)
- [x] **Short Description**: Formatted (under 80 character limit)
- [x] **Full Description**: Formatted with real application features
- [x] **Release Notes**: Formatted for production v1.0.0
- [ ] **Privacy Policy URL**: Link your deployed host privacy policy URL on Google Play Console
- [ ] **Content Rating Questionnaire**: Complete on Play Console (Rated Everyone / 3+)
- [ ] **Target Audience**: Set to 13+ (Students & Technical Club Community)
- [ ] **Data Safety**: Declare standard authentication & local storage usage
- [ ] **Store Category**: Education / Productivity / Communication
