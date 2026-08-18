# HealMind — Rencana Pengembangan

> Target: International users | Monetisasi: AdMob | Platform: Android | Tech: Flutter

---

## Ringkasan Aplikasi

HealMind adalah aplikasi mental health companion yang menggabungkan 4 fitur utama dalam satu aplikasi:

1. **Mood Journal + Gratitude** — daily mood tracking & journaling
2. **Breathing & Calm** — guided breathing exercises
3. **CBT Toolkit** — cognitive behavioral therapy tools
4. **Daily Affirmations** — positive affirmations

---

## 🚀 Phase 1 — MVP: Mood Journal + Gratitude + Affirmations

### Tujuan
Membuat aplikasi fungsional dengan fitur inti yang bisa langsung dipakai dan menghasilkan revenue AdMob.

### Fitur Detail

#### 1.1 Home Screen
- Sapaan personal berdasarkan waktu (Good morning/afternoon/evening)
- Daily affirmation card (swipeable)
- Quick mood status hari ini
- Streak counter (berapa hari berturut-turut check-in)
- Tombol cepat ke journal & breathing

#### 1.2 Mood Check-in
- Pilih emoji mood: 😊 Great, 😐 Okay, 😢 Sad, 😡 Angry, 😴 Tired
- Optional: tambah catatan singkat
- Warna card berubah sesuai mood
- Hanya bisa check-in 1x per hari (bisa edit)

#### 1.3 Journal Screen
- List journal entries per hari (scrollable)
- Tulis journal entry (judul + isi)
- Gratitude section: 3 hal yang disyukuri
- Auto-save ke Hive
- Edit & delete entry
- Format tanggal: "Monday, 16 Aug 2026"

#### 1.4 Affirmations
- Tampil sebagai card di Home screen
- Swipe untuk lihat afirmasi lainnya
- 30+ afirmasi built-in
- Bisa favorit & simpan
- Share ke sosial media

#### 1.5 Mood Chart
- Grafik batang (bar chart) mood mingguan
- Warna bar sesuai mood
- Bisa switch ke tampilan bulanan
- Library: fl_chart

#### 1.6 Reminder
- Notifikasi lokal setiap hari jam 8-9 PM
- Pesan: "How was your day? Take a moment to journal your thoughts 🌙"
- Bisa diatur on/off & jam di Settings

#### 1.7 AdMob
- Banner ad di bagian bawah (permanen)
- Interstitial setelah 3x journal entry disimpan
- Gunakan test ad ID selama development

#### 1.8 Profile/Settings
- Reminder on/off + jam
- Dark mode toggle
- Data management (export/delete all)
- About & Privacy Policy placeholder

### Tech Stack Phase 1
```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  fl_chart: ^0.68.0
  google_mobile_ads: ^5.1.0
  flutter_local_notifications: ^17.2.0
  intl: ^0.19.0
  google_fonts: ^6.2.0
```

### Deliverables Phase 1
- [ ] App struktur & navigasi
- [ ] Home screen + affirmation card
- [ ] Mood check-in + journal
- [ ] Gratitude list
- [ ] Mood chart mingguan
- [ ] Reminder notifikasi
- [ ] AdMob banner + interstitial
- [ ] Dark mode
- [ ] Settings screen
- [ ] Test di HP Samsung

---

## 🫁 Phase 2 — Breathing & Calm

### Fitur Detail

#### 2.1 Breathing Screen
- Animasi lingkaran yang membesar & mengecil
- CustomPainter untuk animasi smooth
- 3 pola pernapasan:
  - **4-7-8 Breathing**: inhale 4s, hold 7s, exhale 8s
  - **Box Breathing**: inhale 4s, hold 4s, exhale 4s, hold 4s
  - **Deep Belly**: inhale 5s, exhale 5s (simple)
- Pilih durasi: 1, 3, 5, 10 menit
- Visual progress bar
- Haptic feedback setiap transisi (opsional)
- Suara "ding" saat transisi (opsional)

#### 2.2 Calm Sounds
- 4 suara: Rain, Ocean Waves, Forest, White Noise
- Bisa play/pause
- Bisa mix multiple sounds
- Volume slider per suara
- Timer: auto-stop setelah X menit
- Sumber suara: Pixabay / Freesound.org (royalty-free)

#### 2.3 Panic Button
- Floating action button di Home
- Langsung buka breathing exercise 1 menit
- Mode simplifikasi — no UI distractions

#### 2.4 Session Tracker
- Log setiap sesi breathing
- Total menit & sesi per minggu

### Deliverables Phase 2
- [ ] CustomPainter breathing circle animation
- [ ] 3 breathing patterns
- [ ] Session timer
- [ ] Calm sounds player
- [ ] Sound mixer
- [ ] Panic button FAB
- [ ] Session tracker
- [ ] AdMob interstitial setelah sesi selesai
- [ ] Test di HP Samsung

---

## 🧠 Phase 3 — CBT Toolkit

### Fitur Detail

#### 3.1 Thought Catcher
- Input form: "What negative thought are you experiencing?"
- Timestamp auto-recorded
- Intensity slider (1-10): "How strongly do you believe this thought?"

#### 3.2 Cognitive Distortion Checker
- Checklist 10 cognitive distortions:
  1. All-or-Nothing Thinking
  2. Overgeneralization
  3. Mental Filter
  4. Discounting the Positive
  5. Jumping to Conclusions
  6. Magnification/Minimization
  7. Emotional Reasoning
  8. "Should" Statements
  9. Labeling
  10. Personalization
- Penjelasan singkat untuk setiap distorsi

#### 3.3 Reframe Exercise
- Step-by-step guided reframe:
  1. Identify the thought
  2. Check the evidence (for & against)
  3. Alternative perspective
  4. New balanced thought
- Intensity re-check: apakah berkurang?

#### 3.4 CBT History
- Log semua sesi CBT
- Lihat progress dari waktu ke waktu
- Filter by date

#### 3.5 Daily CBT Tips
- Tips edukasi tentang CBT
- 1 tips per hari, random
- Bisa bookmark

### Deliverables Phase 3
- [ ] Thought catcher form
- [ ] Distortion checklist
- [ ] Reframe exercise (multi-step)
- [ ] CBT history log
- [ ] Daily CBT tips
- [ ] Test di HP Samsung

---

## ✨ Phase 4 — Polish & Premium

### Fitur Detail

#### 4.1 Premium Themes
- Unlock via rewarded ad
- 5+ tema warna (Calm, Ocean, Forest, Sunset, Midnight)
- Tersimpan di Hive

#### 4.2 Advanced Stats
- Mood analytics: rata-rata, tren, pola
- Streak: hari berturut-turut
- Journal word count
- Breathing session stats
- Export data as CSV

#### 4.3 Export
- PDF journal export (mingguan/bulanan)
- Bisa share atau save

#### 4.4 Multi-language
- English (default)
- Indonesian
- (Future: Spanish, French, German)

#### 4.5 App Polish
- App icon (adaptive icon)
- Splash screen
- Onboarding walkthrough (3 slides)
- Rating prompt (setelah 7 hari)

### Deliverables Phase 4
- [ ] Premium themes via rewarded ads
- [ ] Advanced mood analytics
- [ ] PDF export
- [ ] Multi-language (EN + ID)
- [ ] App icon & splash screen
- [ ] Onboarding screens
- [ ] Rating prompt

---

## Monetisasi — Detail AdMob

### Ad Placements
```
Screen                  Ad Type         Frequency
──────────────────────────────────────────────────
Home                    Banner          Permanent bottom
Journal                 Banner          Permanent bottom
Journal (after save)    Interstitial    Every 3rd save
Breathe (after session) Interstitial    Every 2nd session
Breathe sounds          Rewarded        Unlock 1 premium sound
Profile                 Banner          Permanent bottom
Profile                 Rewarded        Remove ads for 24h
Profile                 Rewarded        Unlock premium theme
```

### Test Ad IDs (Development)
```
Banner:        ca-app-pub-3940256099942544/6300978111
Interstitial:  ca-app-pub-3940256099942544/1033173712
Rewarded:      ca-app-pub-3940256099942544/5224354917
```

### Production Ad IDs
- [ ] Ganti dengan Ad Unit ID asli sebelum release
- [ ] Tambahkan App ID di AndroidManifest.xml

---

## Catatan Penting

1. **Semua gratis** — tidak ada API berbayar, tidak ada server, tidak ada subscription
2. **Full offline** — semua data di Hive local storage
3. **Bahasa Inggris** — target internasional, eCPM lebih tinggi
4. **Test di HP Samsung** — setiap phase harus diuji di device fisik
5. **Commit regularly** — gunakan git untuk version control
6. **AdMob test IDs** — jangan pakai ID production selama development