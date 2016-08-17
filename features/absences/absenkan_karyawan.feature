# language: id
# Source: http://github.com/aslakhellesoy/cucumber/blob/master/examples/i18n/id/features/addition.feature
# Updated: Tue May 25 15:52:00 +0200 2010
#
#Pengguna yang dapat mengakses halaman ini adalah pengguna dengan access key present_employee.
#
#Pengguna dapat mengabsenkan karyawan melalui aplikasi sehingga jika terjadi kerusakan pada fingerprint atau terjadi sesuatu yang mengakibatkan karyawan tidak dapat absen dengan fingerprint, karyawan tetap dapat diabsenkan.
#
#Beberapa data yang dibutuhkan untuk melakukan absen:
#- nama karyawan ( auto complete dengan hasil Nama karyawan - NIK - Departemen - Bagian )*
#- jika masuk maka field yang muncul:
#- tanggal kerja *
#- jam mulai kerja*
#- jam selesai kerja * (muncul jika karyawan diabsenkan pada hari sebelum hari ini).
#- lama istirahat dalam menit (muncul jika karyawan diabsenkan pada hari sebelum hari ini).
#- jika tidak masuk maka field yang muncul:
#- tipe tidak masuk *
#- alasan
#
#Skenario:
#1. Pengguna mengabsenkan karyawan masuk hari ini.
#Konteks - Pengguna berada pada halaman daftar absen karyawan.
#- Pengguna klik button 'Absenkan karyawan'
#- Muncul field-field yang ada dan opsi 'masuk' dan 'tidak masuk'
#- Pengguna klik 'masuk' dan memilih tanggal hari ini
#- Muncul field jam mulai kerja.
#- Pengguna melengkapi data dengan data yang valid.
#Ketika - Pengguna klik 'Simpan'
#Maka - Karyawan yang namanya diabsenkan berhasil diabsenkan.
#- Pesan sukses 'Karyawan berhasil diabsenkan' muncul.
#2. Pengguna mengabsenkan karyawan masuk hari sebelum hari ini.
#Konteks - Pengguna berada pada halaman daftar absen karyawan.
#- Pengguna klik button 'Absenkan karyawan'
#- Muncul field-field yang ada dan opsi 'masuk' dan 'tidak masuk'
#- Pengguna klik 'masuk' dan memilih tanggal kemarin/sebelum hari ini.
#- Muncul field jam mulai kerja, jam selesai kerja, dan lama istirahat.
#- Pengguna melengkapi data dengan data yang valid.
#Ketika - Pengguna klik 'Simpan'
#Maka - Karyawan yang namanya diabsenkan berhasil diabsenkan pada tanggal yang telah dipilih.
#- Pesan sukses 'Karyawan berhasil diabsenkan' muncul.
#3. Pengguna mengabsenkan karyawan tidak masuk.
#Konteks - Pengguna berada pada halaman daftar absen karyawan.
#- Pengguna klik button 'Absenkan karyawan'
#- Muncul field-field yang ada dan opsi 'masuk' dan 'tidak masuk'
#- Pengguna klik 'tidak masuk' dan memilih tanggal hari ini/tanggal berapapun.
#- Muncul field tipe tidak masuk dan alasan tidak masuk
#- Pengguna melengkapi data dengan data yang valid.
#Ketika - Pengguna klik 'Simpan'
#Maka - Karyawan yang namanya diabsenkan berhasil diabsenkan tidak masuk.
#- Pesan sukses 'Karyawan berhasil diabsenkan' muncul.
#Tambahan skenario mengenai berbagai jenis shift yang ada, khusus untuk kasus CGN P dilampirkan.

Fitur: Addition
  Untuk menghindari kesalahan konyol
  Sebagai orang yang gak bisa matematika
  Aku ingin diberi tahu jumlah dua bilangan

  Skenario konsep: Menjumlahkan dua bilangan
    Dengan aku sudah masukkan <input_1> ke kalkulator
    Dan aku sudah masukkan <input_2> ke kalkulator
    Ketika aku tekan <button>
    Maka hasilnya harus <output> di layar

    Contoh:
      | input_1 | input_2 | button | output |
      | 20      | 30      | add    | 50     |
      | 2       | 5       | add    | 7      |
      | 0       | 40      | add    | 40     |
