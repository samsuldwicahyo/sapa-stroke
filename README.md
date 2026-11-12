# SAPA Stroke

Aplikasi Flutter untuk membantu pasien stroke menyampaikan kebutuhan dasar melalui tombol besar dan suara bahasa Indonesia.

## Fitur

- Tombol kebutuhan, keluarga, perasaan, dan jawaban singkat.
- Text-to-Speech bahasa Indonesia dengan pengaturan kecepatan, volume, dan nada.
- Mode landscape, ukuran teks, pilihan tangan, dan pemilihan otomatis untuk aksesibilitas.
- Audio tawa, tombol darurat dengan konfirmasi, alarm lokal, dan getaran.
- Riwayat komunikasi lokal serta pengaturan pendamping.

## Teknologi

Flutter/Dart (Dart >=3.5), Provider, flutter_tts, audioplayers, shared_preferences, vibration, dan wakelock_plus. Android adalah target utama. Folder platform lain masih berupa scaffold dan belum dibuktikan setara.

## Menjalankan

Pasang Flutter SDK, Android SDK, dan mesin TTS bahasa Indonesia pada perangkat:

```powershell
flutter pub get
flutter run --dart-define=SAPA_DEMO_PIN=0000
```

PIN di atas hanya untuk demonstrasi. Ubah PIN pendamping melalui pengaturan aplikasi sebelum dipakai pada perangkat pribadi. Nama keluarga awal memakai label contoh dan dapat diubah melalui pengaturan.

## Pemeriksaan

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

Konfigurasi Android saat ini memakai compile/target SDK 34; dependency audio tertentu dapat memerlukan SDK yang lebih baru. Sesuaikan SDK pada checkout Anda bila Gradle melaporkan kebutuhan tersebut.

## Struktur dan batas

`lib/providers/` mengelola state, `lib/services/` menangani suara/penyimpanan/pemilihan otomatis, dan `lib/screens/` berisi layar aplikasi. Komunikasi, alarm, dan riwayat berjalan lokal; tombol darurat tidak menghubungi layanan darurat atau keluarga secara otomatis. Data pengguna, cache Flutter, konfigurasi SDK lokal, dan signing tidak disertakan.
