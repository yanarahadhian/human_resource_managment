# language: en
# Source: http://github.com/aslakhellesoy/cucumber/blob/master/examples/i18n/en/features/addition.feature
# Updated: Tue May 25 15:51:43 +0200 2010

#Pengguna yang dapat mengakses halaman ini adalah pengguna yang memiliki access key holiday_edit.
#
#Pengguna mengedit data libur nasional yang sudah terdaftar sehingga pengguna bisa memperbaiki kesalahan input yang terjadi.
#Data yang bisa diedit:
#- Nama hari libur *
#- Periode hari libur *
#- Lama hari libur * (akan terisi secara otomatis, non editable)
#- Termasuk cuti bersama, yang jika diceklist akan muncul jumlah hari termasuk cuti bersama
#
#Skenario:
#1. Pengguna mengedit keseluruhan data hari libur dengan data yang valid.
#Konteks - Pengguna mengakses halaman daftar hari libur.
#- Pengguna memilih salah satu nama hari libur.
#- Pengguna masuk ke halaman edit hari libur, dengan semua field nilainya terpopulate sesuai dengan data yang sebelumnya.
#- Pengguna edit semua data tersebut dengan nilai baru yang valid
#Ketika - Pengguna klik button 'Simpan'
#Maka - Data hari libur terpilih terupdate sesuai dengan inputan pengguna.
#- Pengguna kembali ke halaman daftar libur perusahaan.
#- Pesan sukses edit 'Data hari libur berhasil teredit' muncul.
#2. Pengguna mengedit hanya beberapa data hari libur dengan data yang valid.
#Konteks - Pengguna mengakses halaman daftar hari libur.
#- Pengguna memilih salah satu nama hari libur.
#- Pengguna masuk ke halaman edit hari libur, dengan semua field nilainya terpopulate sesuai dengan data yang sebelumnya.
#- Pengguna edit beberapa data tersebut dengan nilai baru yang valid
#Ketika - Pengguna klik button 'Simpan'
#Maka - Data hari libur terpilih terupdate sesuai dengan inputan pengguna.
#- Pengguna kembali ke halaman daftar libur perusahaan.
#- Pesan sukses edit 'Data hari libur berhasil teredit' muncul.
#3. Pengguna mengedit keseluruhan data hari libur dengan data yang tidak valid.
#Konteks - Pengguna mengakses halaman daftar hari libur.
#- Pengguna memilih salah satu nama hari libur.
#- Pengguna masuk ke halaman edit hari libur, dengan semua field nilainya terpopulate sesuai dengan data yang sebelumnya.
#- Pengguna edit semua data tersebut dengan nilai baru yang tidak valid.
#- Sistem memunculkan alert untuk menunjukkan periode libur tidak valid.
#- Pengguna mengganti data periode libur dengan data yang valid.
#Ketika - Pengguna klik button 'Simpan'
#Maka - Data tidak berhasil tersimpan
#- Pengguna tetap berada pada halaman tambah hari libur.
#- Pesan error muncul 'Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali'.
#- Muncul pesan error pada field periode cuti bersama.
#4. Pengguna batal mengedit data hari libur nasional.
#Konteks - Pengguna mengakses halaman daftar hari libur.
#- Pengguna memilih salah satu nama hari libur.
#- Pengguna masuk ke halaman edit hari libur, dengan semua field nilainya terpopulate sesuai dengan data yang sebelumnya.
#- Pengguna edit semua data tersebut dengan nilai baru yang valid
#Ketika - Pengguna klik button 'Batal'
#Maka - Pengguna kembali ke halaman daftar libur perusahaan.
