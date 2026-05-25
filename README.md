📚 CampusNotes
CampusNotes adalah aplikasi mobile untuk mahasiswa yang membantu menyimpan, mengorganisir dan berbagi catatan kuliah secara efisien.

🎯 Permasalahan
Mahasiswa sering kesulitan dalam:
- Mengorganisir catatan per semester dan mata kuliah
- Berbagi catatan dengan teman sekelas
- Tracking catatan dari berbagai mata kuliah
- Mengakses catatan teman untuk belajar bersama

💡 Solusi
CampusNotes menyediakan:
✅ Penyimpanan catatan terstruktur per Semester → Mata Kuliah → File
✅ Sistem sharing catatan antar mahasiswa yang sudah berteman
✅ Tracking catatan dari setiap semester dan mata kuliah
✅ Profile mahasiswa dengan info Binusian, Major, dan Campus


## 🏗️ Architecture

CampusNotes menggunakan **Microservice Architecture** yang terdiri dari:

**Flutter (Mobile App)** → **API Gateway (Port 3000)**

API Gateway meneruskan request ke:
- **Auth Service (Port 3001)** → auth_db (MySQL)
- **Study Service (Port 3002)** → study_db (MySQL)

Services:
1. Auth Service
- Mengelola autentikasi user (register, login)
- Mengelola data profil user
- Mengelola sistem pertemanan (add friend, accept/reject)

2. Study Service
- Mengelola data semester, mata kuliah, dan file catatan
- Upload dan penyimpanan file
- Akses catatan antar teman

3. API Gateway
- Single entry point untuk semua request dari Flutter
- Forward request ke service yang sesuai
- Swagger API Documentation tersedia di /api

🎨 Design Patterns
Selama development CampusNotes, beberapa design pattern digunakan:
1. Repository Pattern
- Digunakan di NestJS melalui Prisma ORM
- Memisahkan logika akses database dari business logic
- Contoh: SemestersService, FriendsService

2. Singleton Pattern
- Digunakan di Flutter untuk service classes
- AuthService, StudyService, FriendService hanya dibuat sekali
- Memastikan satu instance service digunakan di seluruh app

3. Provider Pattern
- Digunakan di Flutter melalui package provider
- AuthProvider mengelola state autentikasi secara global
- Memungkinkan semua widget mengakses data user

4. Gateway Pattern
- API Gateway sebagai single entry point
- Menyederhanakan komunikasi antara Flutter dan multiple services

5. Guard Pattern
- Digunakan di NestJS melalui JwtAuthGuard
- Melindungi endpoint yang membutuhkan autentikasi
- Memverifikasi JWT token di setiap request

6. DTO Pattern (Data Transfer Object)
- Digunakan di NestJS untuk validasi input
- Contoh: RegisterDto, LoginDto, CreateSemesterDto


🛠️ Tech Stack
Frontend
Flutter — Cross-platform mobile framework
Dart — Programming language
Provider — State management
HTTP — API communication

Backend
NestJS — Node.js framework untuk membangun service
TypeScript — Programming language
Prisma ORM — Database access layer
JWT — Authentication token
Passport.js — Authentication middleware
Swagger — API documentation

Database
MySQL — Relational database
auth_db — Menyimpan data user dan pertemanan
study_db — Menyimpan data semester, course, dan file


📱 Features
Halaman 1 — Your Notes
- Buat dan kelola semester
- Buat dan kelola mata kuliah per semester
- Upload dan akses file catatan
- Edit nama dan cover semester/mata kuliah

Halaman 2 — Friends Notes
- Cari dan tambah teman mahasiswa
- Terima atau tolak friend request
- Kunjungi catatan teman yang sudah berteman
- Badge notifikasi friend request

Halaman 3 — Profile
- Lihat dan edit profil (username, binusian, major, campus)
- Upload foto profil dan cover
- Logout
