# HealMind — TODO List

> Last updated: 18 August 2026
> Current phase: Phase 4 — Polish & Premium ✅
> Total progress: 100%

---

## Phase 1 — MVP (Mood Journal + Gratitude + Affirmations) ✅

### ✅ Setup & Structure
- [x] Tambahkan dependencies ke pubspec.yaml
- [x] Buat `lib/app.dart` — MaterialApp, theme, bottom navigation
- [x] Buat `lib/constants/colors.dart`, `strings.dart`, `affirmations.dart`
- [x] Setup Hive: init, open boxes

### ✅ Data Models
- [x] `lib/models/mood.dart`, `mood_entry.dart`, `journal_entry.dart`, `affirmation.dart`, `user_settings.dart`

### ✅ Services
- [x] `lib/services/hive_service.dart`, `notification_service.dart`, `admob_service.dart`

### ✅ Screens
- [x] home, journal, journal_detail, mood_check, mood_chart, settings

### ✅ Widgets
- [x] affirmation_card, mood_emoji_picker, mood_bar, gratitude_input, streak_badge, ad_banner_widget

### ✅ Navigation + FAB + flutter analyze (0 issues)

---

## Phase 2 — Breathing & Calm ✅

### ✅ Breathing
- [x] CustomPainter breathing circle animation (`lib/widgets/breathing_circle.dart`)
- [x] 3 breathing patterns: 4-7-8, Box, Deep Belly (`lib/constants/breathing_patterns.dart`)
- [x] Session timer: 1/3/5/10 min (`lib/widgets/session_timer_picker.dart`)
- [x] Pattern selector (`lib/widgets/breathing_pattern_selector.dart`)
- [x] Haptic feedback on transition
- [x] Session tracker via Hive (`breathing_sessions` box)
- [x] Full breathing tab (`lib/screens/breathe_screen.dart`)
- [x] Animated session screen (`lib/screens/breathing_session_screen.dart`)
- [x] Panic button on Home screen (1-min Deep Belly)

---

## Phase 3 — CBT Toolkit ✅

### ✅ Thought Reframer
- [x] Thought catcher form (`lib/screens/cbt_reframe_screen.dart` Step 1)
- [x] Intensity slider 1-10 (`lib/widgets/intensity_slider.dart`)
- [x] 10 cognitive distortions checklist (`lib/widgets/distortion_checklist.dart`)
- [x] 4-step reframe wizard (Catch → Identify → Rate → Reframe)
- [x] CBT history log (`lib/services/hive_service.dart` cbt_entries box)
- [x] CBT entry model (`lib/models/cbt_entry.dart`)

### ✅ CBT Tips
- [x] 35 CBT educational tips (`lib/constants/cbt_data.dart`)
- [x] Daily random tip card (`lib/widgets/cbt_tip_card.dart`)
- [x] Full CBT tab with history & stats (`lib/screens/cbt_screen.dart`)

### ✅ Code Quality
- [x] `flutter analyze` — **0 issues**

---

## Phase 2.5 — Calm Sounds ✅

### ✅ Calm Sounds
- [x] CalmSoundService — programmatic WAV generation (no external assets)
- [x] 4 ambient sounds: Rain, Ocean Waves, Forest, White Noise
- [x] Play/pause toggle per sound
- [x] Volume slider per sound
- [x] Mix multiple sounds simultaneously
- [x] Sleep timer (15/30/45/60/90 min auto-stop)
- [x] CalmSoundsScreen full UI
- [x] Integrated into Breathe tab
- [x] `flutter analyze` — **0 issues**

---

## Phase 3.5 — AdMob Integration ✅

### ✅ Ad Units
- [x] Banner: `ca-app-pub-1691052555871805/8383604628`
- [x] Interstitial: `ca-app-pub-1691052555871805/7051864168`
- [x] Native: `ca-app-pub-1691052555871805/4915132903`
- [x] App Open: `ca-app-pub-1691052555871805/2983104137`
- [x] Rewarded: `ca-app-pub-1691052555871805/4425700829`

### ✅ Placements
- [x] Banner: Home, Journal, Breathe, CBT, Settings (bottom)
- [x] Native: Home, Journal (tiap 3 entry), Breathe, Calm Sounds
- [x] Interstitial: setiap 3x journal/CBT save, setiap 2x breathing session
- [x] App Open: saat app resume dari background
- [x] Rewarded: Remove ads 24h + Unlock premium themes (Settings)
- [x] `flutter analyze` — **0 issues**

---

## Phase 4 — Polish & Premium ✅

### ✅ Calm Sounds
- [x] Calm ambient sounds (Rain, Ocean, Forest, White Noise)

### ✅ Premium
- [x] Rewarded ad integration
- [x] "Remove ads for 24h" feature
- [x] 5 premium color themes (Ocean, Sunset, Forest, Rose, Midnight)
- [x] Breathing circle phase colors (Biru=Tarik, Oranye=Tahan, Ungu=Buang, Teal=Diam)

### ✅ Enhancement
- [x] Advanced mood analytics (pie chart, trend bar, day-of-week, insights)
- [x] PDF journal export (pdf + share_plus)
- [x] Multi-language EN + ID (L10n service, AppStringsId, wired to all screens)
- [x] App icon (adaptive, flutter_launcher_icons, lavender background)
- [x] Splash screen (launch_background.xml with app icon centered)
- [x] Onboarding (3 slides)
- [x] Rating prompt after 7 days

---

## Bugs & Notes
- [x] AGP/Gradle version compatibility fixed (AGP 8.11.1, Gradle 8.13, Kotlin 2.2.20)
- [x] JVM memory fixed (-Xmx1536M for 4GB RAM laptop)
- [x] AdMob App ID added to AndroidManifest
- [x] Core library desugaring enabled for flutter_local_notifications
- [x] Audio files for ambient sounds — generated programmatically, no external assets needed
- [x] Replace test AdMob IDs with real ones — Production IDs installed
- [x] Test device registered (FEE5DE1E2CCCB171B365A72A341EF8D2)
- [x] NativeAd API migration (google_mobile_ads 5.3.1): factoryId → nativeTemplateStyle
- [x] flutter analyze — **0 issues**
- [x] Deleted placeholder files (breathe_placeholder, cbt_placeholder)
- [x] Removed unused strings.dart imports from all files
- [ ] ⚠️ Banner ads may not show yet — unit AdMob baru butuh 24-48 jam untuk aktif.

---

## CI/CD & Release — GitHub Actions ✅

### GitHub Repository
- **URL**: https://github.com/projectlabs26-ui/healmind-app
- **Branch**: `main`
- **Akun GitHub**: `projectlabs26-ui`

### Workflow: Build APK
- **File**: `.github/workflows/build.yml`
- **Trigger**: Push ke branch `main` atau manual (workflow_dispatch)
- **Build**: Debug APK (`flutter build apk --debug`)
- **Artifacts**: `healmind-debug-apk` (retention 7 hari)

### Cara Build APK via GitHub Actions
1. Push kode ke branch `main`
2. Buka repo → tab **Actions**
3. Tunggu workflow selesai (✅ hijau)
4. Klik workflow → bagian **Artifacts**
5. Download `healmind-debug-apk.zip`
6. Extract → install APK ke HP

### Release APK (Jika Diperlukan)
#### Signing Key
- Generate keystore:
  ```bash
  keytool -genkey -v -keystore healmind-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias healmind
  ```
- **Jangan commit keystore ke GitHub!**

#### Setup Secrets di GitHub
1. Buka repo → **Settings** → **Secrets and variables** → **Actions**
2. Tambahkan secrets:
   - `KEYSTORE_BASE64`: `base64 -i healmind-key.jks`
   - `KEYSTORE_PASSWORD`: Password keystore
   - `KEY_PASSWORD`: Password key

#### Update Workflow untuk Release
Edit `.github/workflows/build.yml`:
```yaml
- name: Decode keystore
  run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > app/keystore.jks

- name: Build APK (Release)
  run: flutter build apk --release
  env:
    KEY_STORE_FILE: keystore.jks
    KEY_STORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
    KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
    KEY_ALIAS: healmind
```

### Troubleshooting
#### Error 403 Permission Denied
- **Penyebab**: Credential cache Windows menyimpan akun GitHub lain
- **Solusi**:
  1. Hapus credential lama:
     ```powershell
     cmdkey /delete:git:https://github.com
     ```
  2. Set credential helper ke gh CLI:
     ```bash
     git config --global credential.helper "!'/c/Program Files/GitHub CLI/gh.exe' auth git-credential"
     ```
  3. Login ke gh CLI:
     ```bash
     gh auth login --web
     ```

### Build di Laptop 4GB RAM
- ⚠️ Build lokal kemungkinan gagal karena kurang RAM
- ✅ **Rekomendasi**: Gunakan GitHub Actions (cloud build)
- Workflow gratis untuk public repo (2000 menit/bulan)

### Checklist Release
- [ ] Semua fitur Phase 1-4 sudah selesai ✅
- [ ] `flutter analyze` — 0 issues ✅
- [ ] Test di device fisik (Samsung Galaxy A07)
- [ ] Ganti AdMob test IDs dengan production IDs
- [ ] Generate signing key untuk release APK
- [ ] Setup GitHub secrets untuk signing
- [ ] Build release APK via GitHub Actions
- [ ] Test install di minimal 3 HP berbeda
- [ ] Upload ke Google Play Store (opsional)