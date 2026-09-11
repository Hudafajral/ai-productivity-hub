# 🧠 AI Productivity Hub (AI Notion Notebook)

Ekosistem produktivitas cerdas berbasis arsitektur *decoupled full-stack*. Menggabungkan **Flutter** untuk antarmuka mobile modern dengan arsitektur alarm native yang persisten, didukung oleh **FastAPI** berkinerja tinggi, basis data relasional **PostgreSQL**, serta mesin **RAG (Retrieval-Augmented Generation)** terintegrasi **Google Gemini Multimodal AI** untuk mengonversi catatan, dokumen, dan agenda harian menjadi asisten cerdas interaktif.

---

## 🛠️ Tech Stack & Bahasa Pemrograman

* **Mobile Client:** Dart & Flutter (Material Design 3, Google Sign-In v6.2.1, SharedPreferences, Alarm Service, Local Notifications)
* **Backend API:** Python 3.10+ (FastAPI, Uvicorn, Asyncio, Pydantic)
* **Database & ORM:** PostgreSQL & SQLAlchemy / Alembic (Database Migrations)
* **Artificial Intelligence:** Google Gemini API & Custom RAG Engine
* **Native Android Integration:** Kotlin, Android Foreground Service, Exact Alarms System, Custom Ringtone Stream

---

## 📥 Prasyarat Perangkat Lunak

Pastikan perangkat lunak berikut telah terpasang di komputer Anda sebelum memulai instalasi:

1. **Flutter SDK (v3.19 atau lebih baru)**
   * Unduh: [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
   * Jalankan `flutter doctor` di terminal untuk memastikan tidak ada komponen Android yang terlewat.

2. **Java Development Kit (JDK 17 / JBR Android Studio)**
   * Direkomendasikan menggunakan bawaan Android Studio (`C:\Program Files\Android\Android Studio\jbr`).

3. **Python (v3.10 atau lebih baru)**
   * Unduh: [python.org/downloads](https://python.org/downloads/)
   * ⚠️ *Wajib saat instalasi di Windows:* Centang opsi **"Add Python to PATH"**.

4. **PostgreSQL Database**
   * Gunakan PostgreSQL lokal via [postgresql.org](https://www.postgresql.org/) atau database cloud instan via [Supabase](https://supabase.com/).

5. **Google Cloud Console Credentials (OAuth 2.0)**
   * Dapatkan sertifikat SHA-1 laptop Anda dan daftarkan pada Google Cloud Console untuk fitur Google Sign-In.

---

## 📂 Struktur Direktori Repositori

```text
my-ai-notion-notebook/
├── backend_app/                       # REST API, Database Engine & RAG (FastAPI)
│   ├── alembic/                       # Skrip migrasi skema database relasional
│   ├── app/
│   │   ├── api/v1/                    # Endpoints (notebooks, notes, schedules)
│   │   ├── core/                      # Konfigurasi aplikasi, env, & database connection
│   │   ├── models/                    # Definisi tabel SQLAlchemy ORM
│   │   ├── schemas/                   # Pydantic data validation contracts
│   │   ├── services/                  # Gemini Multimodal API & RAG Engine
│   │   └── main.py                    # Entrypoint server FastAPI
│   ├── requirements.txt               # Daftar pustaka Python backend
│   └── .env.example                   # Contoh konfigurasi environment backend
├── mobile_app/                        # Aplikasi Mobile Client (Flutter)
│   ├── android/                       # Native Android layer, manifest, & permissions
│   ├── assets/audio/                  # Nada dering kustom alarm (.mp3)
│   ├── lib/
│   │   ├── core/                      # Theme, API Client, & App Constants
│   │   ├── features/
│   │   │   ├── auth/                  # Layar masuk/daftar & Google Sign-In flow
│   │   │   ├── home/                  # Navigasi utama & manajemen profil user
│   │   │   ├── notebook/              # Chatbot AI interaktif & document upload
│   │   │   ├── notes/                 # Dynamic block-based rich text note editor
│   │   │   └── schedule/              # Manajemen jadwal & fullscreen alarm overlay
│   │   ├── services/                  # AuthService, AlarmService, NotificationService
│   │   └── main.dart                  # Root widget & global navigator listener
│   └── pubspec.yaml                   # Manifest paket dependensi Flutter
├── .gitignore                         # Filter keamanan berkas sampah & kredensial
└── README.md                          # Dokumentasi resmi proyek
```

---

## 🚀 Panduan Menjalankan Aplikasi

Aplikasi ini berjalan secara *decoupled*. Backend (FastAPI) dan Frontend Mobile (Flutter) dijalankan secara independen melalui dua terminal terpisah.

### Terminal 1: Menjalankan Backend (FastAPI)

1. **Buka terminal dan masuk ke folder `backend_app`:**
   ```bash
   cd backend_app
   ```

2. **Buat dan aktifkan Virtual Environment Python:**

   * **Windows (PowerShell):**
     ```powershell
     python -m venv venv
     .\venv\Scripts\Activate.ps1
     ```

   * **Linux / macOS:**
     ```bash
     python3 -m venv venv
     source venv/bin/activate
     ```

3. **Instal seluruh pustaka Python:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Siapkan berkas konfigurasi `.env`:**

   Salin berkas template `.env.example` menjadi `.env`:
   ```bash
   cp .env.example .env
   ```

   Buka berkas `.env` dan lengkapi konfigurasi database serta API Key:
   ```env
   DATABASE_URL=postgresql://user:password@localhost:5432/ai_productivity_hub
   GEMINI_API_KEY=masukkan_api_key_google_gemini_anda
   PORT=8000
   ```

5. **Jalankan migrasi database dan nyalakan server:**
   ```bash
   alembic upgrade head
   uvicorn app.main:app --reload --port 8000 --host 0.0.0.0
   ```

   * Backend aktif di: `http://localhost:8000`
   * Dokumentasi Swagger API: `http://localhost:8000/docs`

### Terminal 2: Menjalankan Mobile App (Flutter)

1. **Buka terminal baru dan masuk ke folder `mobile_app`:**
   ```bash
   cd mobile_app
   ```

2. **Unduh seluruh package dependensi Flutter:**
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Variabel Lingkungan Java (Khusus Windows jika belum terdaftar):**
   ```powershell
   $env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
   $env:Path = "$env:JAVA_HOME\bin;$env:Path"
   ```

4. **Jalankan aplikasi di perangkat fisik Android atau Emulator:**
   ```bash
   flutter run
   ```

---

## 🧪 Alur Kerja Sistem (Workflow)

```text
[ Pengguna ] ──▶ Akses Aplikasi Flutter (Mobile Client)
                    │
                    ├── 1. Autentikasi: Local SharedPreferences / Single Sign-On (Google Sign-In)
                    ├── 2. Manajemen Catatan: Disimpan dan diindeks oleh Mesin RAG (FastAPI + Gemini)
                    └── 3. Penjadwalan & Alarm:
                            │
                            ├── Alarm Native System (Background Service & Exact Alarm Permission)
                            ├── Stream Listener Menangkap Trigger Jam Berdering
                            ▼
                    [ Layar Alarm Ringing ] ──▶ Bunyikan Audio Stream & Tampilkan Tombol Tunda/Matikan
```

---

## 🔧 Solusi Kendala Umum (Troubleshooting)

* **Error Signing Report:** `JAVA_HOME is not set and no 'java' command could be found in your PATH`
  * **Solusi:** Setel sementara path JDK bawaan Android Studio di terminal PowerShell sebelum menjalankan Gradle:
    ```powershell
    $env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
    $env:Path = "$env:JAVA_HOME\bin;$env:Path"
    ./gradlew signingReport
    ```

* **Error Panggilan API Google Sign-In:** `The class 'GoogleSignIn' doesn't have an unnamed constructor`
  * **Solusi:** Versi 7.x mengalami *breaking changes*. Pastikan versi package dikunci ke `^6.2.1` di `pubspec.yaml`, lalu jalankan `flutter pub get`.

* **Layar Alarm Tidak Muncul Saat Audio Berdering:**
  * **Penyebab:** Widget `MaterialApp` belum dipasangi referensi routing global.
  * **Solusi:** Tambahkan `navigatorKey: navigatorKey` ke dalam konfigurasi `MaterialApp` di file `main.dart`.
