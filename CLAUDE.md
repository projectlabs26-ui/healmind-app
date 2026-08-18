# HealMind App — Mental Health Therapy Companion

> "Your daily mental wellness companion"
> Target: International users (US, UK, Europe, Australia) → high AdMob eCPM
> Language: English (default)

---

## Environment Setup

### Prerequisites
- **Flutter**: 3.44.8 (stable) + Dart 3.12.2
- **Java**: OpenJDK 21.0.12 (Temurin) at `C:\Program Files\Eclipse Adoptium\jdk-21.0.12.8-hotspot\`
- **Android SDK**: `C:\Android` (platforms: 34, 35, 36; build-tools: 35.0.0, 36.0.0)
- `ANDROID_HOME` = `C:\Android`
- `JAVA_HOME` = `C:\Program Files\Eclipse Adoptium\jdk-21.0.12.8-hotspot`

### Test Device
- **Samsung Galaxy A07 (SM A075F)**
- Connect via **WiFi ADB** (USB cable is charge-only, doesn't work for data)
- See **WiFi ADB Connection** section below

### Free Tools Only — No Paid Services
- **Database**: Hive (local, offline)
- **Charts**: fl_chart
- **Ads**: google_mobile_ads (AdMob)
- **Notifications**: flutter_local_notifications
- **Sounds**: Pixabay / Freesound.org (royalty-free)
- **Icons/Illustrations**: SVGRepo / unDraw (free)
- **Fonts**: Google Fonts (Inter, Poppins)
- **No backend, no API, no server, no Firebase**

---

## WiFi ADB Connection

1. **Phone**: Settings → Developer Options → Enable **Wireless debugging**
2. **Pair** (first time per session):
   - Phone: Pair device with pairing code → 6-digit code + IP:Port
   - Laptop: `adb pair <IP:Port> <code>`
3. **Connect**:
   - Phone: Note IP address & Port on Wireless debugging main page
   - Laptop: `adb connect <IP:Port>`
4. **Verify**: `adb devices`
5. **Run**: `flutter run -d <IP:Port>`

IP changes each session — always check phone screen.

---

## App Architecture

### Bottom Navigation (5 tabs)
```
Home | Journal | Breathe | CBT | Profile
```

### State Management
- Simple `StatefulWidget` + `setState` for now
- Upgrade to Provider/Riverpod if complexity grows

### Local Storage (Hive)
```
Box: 'moods'       → List<MoodEntry>
Box: 'journals'    → List<JournalEntry>
Box: 'affirmations'→ List<Affirmation>
Box: 'settings'    → Map (reminder time, theme, etc.)
Box: 'cbt_entries' → List<CBTEntry>        (Phase 3)
Box: 'breathing_sessions' → List<Session>  (Phase 2)
```

### Color Palette (Calm & Professional)
- Primary: Soft Lavender (#9B8EC4)
- Secondary: Sage Green (#7BA098)
- Surface: Warm Beige (#F5F0EB)
- Dark mode: Dark Slate (#1E2A2F)

---

## AdMob Strategy

| Placement | When | Target eCPM (US) |
|-----------|------|------------------|
| Banner (320×50) | Permanent bottom | $0.50–$2 |
| Interstitial | Every 3 journal entries / after breathing session | $3–$8 |
| Rewarded | Unlock premium themes / remove ads 1 day | $5–$15 |

**Note:** AdMob App ID and Ad Unit IDs need to be added before release.
During development, use test ad IDs.

---

## Phased Development Plan

### Phase 1 — MVP: Mood Journal + Gratitude + Affirmations
Status: ✅ Complete
- Bottom navigation (Home, Journal, Breathe, CBT, Profile)
- Daily mood check-in with emoji picker
- Journal entry + gratitude list
- Daily affirmation card (swipeable)
- Weekly mood chart (fl_chart)
- Local notification reminder (8-9 PM)
- AdMob banner + interstitial + native + rewarded + app open
- Hive local storage

### Phase 2 — Breathing & Calm
Status: ✅ Complete
- Animated breathing circle (CustomPainter)
- Patterns: 4-7-8, Box Breathing, Deep Belly
- Session timer (1/3/5/10 min)
- Calm ambient sounds (Rain, Ocean, Forest, White Noise) — programmatic WAV generation
- Home screen panic button widget (1-min Deep Belly)
- Session tracker via Hive

### Phase 3 — CBT Toolkit
Status: ✅ Complete
- Thought catcher form with 4-step reframe wizard
- 10 cognitive distortions checklist
- Intensity slider (1-10)
- CBT history log (Hive cbt_entries box)
- 35 daily CBT tips (cbt_data.dart)

### Phase 4 — Polish & Premium
Status: ✅ Complete
- 5 premium color themes (Ocean, Sunset, Forest, Rose, Midnight) via rewarded ads
- Advanced mood analytics (pie chart, trend bar, day-of-week, insights)
- PDF journal export (pdf + share_plus)
- Multi-language EN + ID (L10n service, AppStringsId)
- Adaptive app icon (lavender background)
- Splash screen (launch_background.xml)
- Onboarding (3 slides)
- Rating prompt after 7 days
- Remove ads for 24h feature

---

## Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point |
| `lib/app.dart` | MaterialApp, theme, navigation |
| `lib/models/` | Data models |
| `lib/screens/` | Screen widgets per tab |
| `lib/widgets/` | Reusable components |
| `lib/services/` | Hive, notifications, AdMob |
| `lib/constants/` | Colors, strings, breathing patterns |
| `RENCANA.md` | Full detailed plan |
| `TODO.md` | Current task list |
| `.github/workflows/build.yml` | GitHub Actions workflow |

---

## CI/CD — GitHub Actions

### Repository
- **GitHub**: https://github.com/projectlabs26-ui/healmind-app
- **Branch**: `main`
- **Akun**: `projectlabs26-ui`

### Build APK
Workflow otomatis build **Debug APK** saat push ke `main`:
1. Push kode ke `main`
2. Buka repo → tab **Actions**
3. Tunggu workflow selesai (✅ hijau)
4. Download APK dari **Artifacts**

### Release APK (Production)
Untuk release APK yang bisa diinstall tanpa warning:
1. Generate signing key
2. Setup GitHub secrets
3. Update workflow untuk build release
4. Lihat `TODO.md` → section **CI/CD & Release**

### Troubleshooting Build
- **4GB RAM laptop**: Build lokal kemungkinan gagal → pakai GitHub Actions
- **403 Permission**: Hapus credential cache Windows, pakai `gh auth login`
- Lihat `TODO.md` → section **Troubleshooting**