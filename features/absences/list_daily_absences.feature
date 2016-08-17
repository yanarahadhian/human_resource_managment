# language: id
# Source: http://github.com/aslakhellesoy/cucumber/blob/master/examples/i18n/en/features/addition.feature
# Updated: Tue May 25 15:51:43 +0200 2010
#Pengguna yang dapat mengakses fitur ini adalah pengguna dengan access key present_index.
#
#Pengguna melihat absensi karyawan untuk mengetahui/memantau kedisiplinan karyawan.
#Daftar absensi karyawan dapat difilter berdasarkan departemen, bagian, group, periode, shift.
#
#Pertukaran data dengan mesin fingerprint akan dilakukan sistem pada background, dengan aturan data terupdate setiap 10 menit sekali dengan catatan, konfigurasi fingerprint yang sesuai dengan yang digunakan telah dilakukan pengguna pada aplikasi ini.
#
#Pengguna juga dapat menyesuaikan absensi karyawan, jika karyawan sudah melakukan absen sebelum karyawan tersebut di assign ke shift tertentu pada periode tersebut. Akan ada button 'Sesuaikan absensi' di halaman ini.
#
#Skenario:
#1. Pengguna melihat daftar absensi karyawan.
#Konteks - Pengguna melihat daftar absensi karyawan.
#Ketika - Pengguna mengakses daftar absensi karyawan.
#Maka - Jika sudah ada absensi karyawan maka daftar absensi karyawan dimunculkan.
#- Jika belum ada absensi karyawan maka muncul pesan handle blank slate yang sesuai standar 'Belum ada data absensi karyawan' 'Silahkan 'Absenkan Karyawan' untuk mengabsenkan karyawan'.
#2. Pengguna melihat daftar absensi karyawan dengan filter.
#Konteks - Pengguna melihat daftar absensi karyawan dengan filter tertentu.
#- Pengguna memilih filter dan memasukkan nilai pada filter-filter tersebut.
#Ketika - Pengguna klik 'Go'
#Maka - Jika sudah ada absensi karyawan sesuai dengan filter yang ditentukan maka daftar absensi karyawan dimunculkan.
#- Jika belum ada absensi karyawan sesuai dengan filter maka muncul pesan handle hasil filter yang sesuai standar 'Belum ada data absensi karyawan yang sesuai' 'Silahkan 'Reset Filter' atau ganti parameter nilai filter Anda'.
#3. Pengguna menyesuaikan absensi karyawan.
#Konteks - Pengguna baru memasukkan schedule baru dan ingin menyesuaikan data absensi karyawan yang mungkin belum terassign ke shift pada periode tertentu.
#- Pengguna berada pada halaman absensi karyawan.
#Ketika - Pengguna klik button 'Sesuaikan absensi'
#Maka - Jika ada absensi karyawan yang belum terassign ke shift maka absensi karyawan pada periode tersebut akan secara otomatis terasosiasi pada shift tertentu. Pesan sukses 'Absen karyawan berhasil terasosiasi pada shift' muncul.
#- Jika tidak ada absensi karyawan yang perlu terasosiasi pada shift maka pesan 'Maaf, tidak ada data absensi yang perlu disesuaikan saat ini' muncul.


Fitur: Daftar Absensi Harian
  Untuk mengakses halaman Daftar Absensi Harian Karyawan
  Sebagai pengguna yang memiliki akses present_index
  Saya Ingin melihat daftar karyawan yang hadir dihari ini atau dihari lain

Dasar: Insert data
Dengan Inisialisasi data absensi
Dan pengguna telah login

  Skenario: Pengguna membuka halaman absensi
    Ketika pengguna berkunjung ke absences page
    Maka pengguna dapat melihat 1 buah record absensi
    Dan pengguna seharusnya melihat "Test Present Today"

  Skenario: Pengguna menggunakan filter pada halaman absensi
    Ketika pengguna mengisikan filter tanggal
    Maka pengguna seharusnya melihat "Absent Today"
    Dan pengguna seharusnya melihat "Present Today"