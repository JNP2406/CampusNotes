# 📚 CampusNotes

CampusNotes adalah aplikasi mobile untuk mahasiswa yang membantu menyimpan, mengorganisir, dan berbagi catatan kuliah secara efisien.

---

## 🎯 Permasalahan

Mahasiswa sering kesulitan dalam:
- Mengorganisir catatan per semester dan mata kuliah
- Berbagi catatan dengan teman sekelas
- Tracking catatan dari berbagai mata kuliah
- Mengakses catatan teman untuk belajar bersama

---

## 💡 Solusi

CampusNotes menyediakan:
- ✅ Penyimpanan catatan terstruktur per **Semester → Mata Kuliah → File**
- ✅ Sistem **sharing catatan** antar mahasiswa yang sudah berteman
- ✅ **Tracking catatan** dari setiap semester dan mata kuliah
- ✅ **Profile mahasiswa** dengan info Binusian, Major, dan Campus

---

## 🏗️ Architecture

CampusNotes menggunakan **Microservice Architecture** yang terdiri dari:

**Flutter (Mobile App)** → **API Gateway (Port 3000)**

API Gateway meneruskan request ke:
- **Auth Service (Port 3001)** → auth_db (MySQL)
- **Study Service (Port 3002)** → study_db (MySQL)

### Services

**1. Auth Service**
- Mengelola autentikasi user (register, login)
- Mengelola data profil user
- Mengelola sistem pertemanan (add friend, accept/reject)

**2. Study Service**
- Mengelola data semester, mata kuliah, dan file catatan
- Upload dan penyimpanan file
- Akses catatan antar teman yang sudah berteman

**3. API Gateway**
- Single entry point untuk semua request dari Flutter
- Forward request ke service yang sesuai
- Swagger API Documentation tersedia di `/api`

---

## 🎨 Design Patterns

**1. Repository Pattern**
Digunakan di NestJS melalui Prisma ORM untuk memisahkan logika akses database dari business logic. Contoh: `SemestersService`, `FriendsService`, `CoursesService`.

**2. Singleton Pattern**
Digunakan di Flutter untuk service classes seperti `AuthService`, `StudyService`, dan `FriendService` — hanya dibuat satu instance dan digunakan di seluruh aplikasi.

**3. Provider Pattern**
Digunakan di Flutter melalui package `provider`. `AuthProvider` mengelola state autentikasi secara global sehingga semua widget dapat mengakses data user.

**4. Gateway Pattern**
API Gateway berfungsi sebagai single entry point yang menyederhanakan komunikasi antara Flutter dan multiple backend services.

**5. Guard Pattern**
Digunakan di NestJS melalui `JwtAuthGuard` untuk melindungi endpoint yang membutuhkan autentikasi dan memverifikasi JWT token di setiap request.

**6. DTO Pattern (Data Transfer Object)**
Digunakan di NestJS untuk validasi input data. Contoh: `RegisterDto`, `LoginDto`, `CreateSemesterDto`, `CreateCourseDto`.

---

## 🛠️ Tech Stack

### Frontend
| Teknologi | Kegunaan |
|-----------|----------|
| Flutter | Cross-platform mobile framework |
| Dart | Programming language |
| Provider | State management |
| HTTP | API communication |

### Backend
| Teknologi | Kegunaan |
|-----------|----------|
| NestJS | Node.js framework untuk membangun service |
| TypeScript | Programming language |
| Prisma ORM | Database access layer |
| JWT | Authentication token |
| Passport.js | Authentication middleware |
| Swagger | API documentation |

### Database
| Database | Kegunaan |
|----------|----------|
| MySQL (auth_db) | Menyimpan data user dan pertemanan |
| MySQL (study_db) | Menyimpan data semester, course, dan file |

---

## 📱 Features

### 📖 Your Notes
- Buat dan kelola semester
- Buat dan kelola mata kuliah per semester
- Upload dan akses file catatan
- Edit nama dan cover semester/mata kuliah
- Hapus semester, course, dan file dengan long press

### 👥 Friends Notes
- Cari dan tambah teman mahasiswa
- Rekomendasi teman berdasarkan pengguna lain
- Terima atau tolak friend request
- Kunjungi catatan teman yang sudah berteman
- Badge notifikasi friend request

### 👤 Profile
- Lihat dan edit profil (username, binusian, major, campus)
- Upload foto profil dan cover
- Logout
