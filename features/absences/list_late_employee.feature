# language: id
# Source: http://github.com/aslakhellesoy/cucumber/blob/master/examples/i18n/id/features/addition.feature
# Updated: Tue May 25 15:52:00 +0200 2010
#
#Pengguna yang dapat mengakses halaman ini adalah pengguna dengan access key late_index.
#
#Pengguna melihat daftar karyawan yang terlambat agar dapat memonitor kegiatan operasional karyawan sehingga kebijakan perusahaan mengenai keterlambatan karyawan dapat terimplementasi dengan baik dan mudah memberikan respon jika keterlambatan bisa ditoleransi.
#
#Keterlambatan karyawan dapat dioverride jika memang keterlambatan memiliki alasan yang jelas.
#
#Skenario:
#1. Pengguna melihat daftar karyawan terlambat.
#Konteks - Pengguna ingin melihat daftar karyawan terlambat.
#Ketika - Pengguna mengakses halaman daftar karyawan terlambat.
#Maka - Jika daftar karyawan terlambat ada maka daftar karyawan terlambat muncul.
#- Jika daftar karyawan terlambat belum ada maka pesan handle blank slate yang sesuai standar muncul 'Belum ada data karyawan terlambat'.
#2. Pengguna melihat daftar karyawan terlambat dengan filter tertentu.
#Konteks - Pengguna ingin melihat daftar karyawan terlambat sesuai filter tertentu.
#- Pengguna menambahkan filter data yang ingin ditampilkan dan memberikan nilainya pada filter-filter tersebut.
#Ketika - Pengguna klik 'Go'.
#Maka - Jika daftar karyawan terlambat yang sesuai dengan filter ada maka daftar karyawan terlambat muncul.
#- Jika hasil filter daftar karyawan yang terlambat dieskpor maka data yang terekspor adalah data karyawan terlambat yang sesuai dengan filter.
#- Jika daftar karyawan terlambat belum ada yang sesuai dengan filter maka pesan handle hasil filter yang sesuai standar muncul 'Tidak ada data karyawan terlambat yang sesuai' 'Silahkan 'Reset Filter' atau ganti parameter filter yang Anda masukkan'.
#3. Pengguna mengoverride keterlambatan karyawan.
#Konteks - Pengguna sudah melihat daftar karyawan terlambat.
#- Pengguna memilih karyawan yang keterlambatannya ingin dioverride.
#- Pengguna memilih 'override' pada 'more actions'.
#- Muncul pop up nama karyawan/nama karyawan pertama yang diceklist jika karyawan yang diceklist jumlahnya lebih dari satu, total lama keterlambatan, field dianggap terlambat berapa menit, alasan keterlambatan, dan opsi semua sama jika karyawan yang dipilih lebih dari satu.
#- Pengguna mengisi semua field yang dibutuhkan dengan data yang valid.
#Ketika - Pengguna klik 'Simpan'.
#Maka - Karyawan terpilh keterlambatannya akan dioverride sesuai dengan inputan pengguna.
#- Pesan sukses 'Keterlambatan karyawan berhasil dioverride' muncul.
#4. Pengguna mengoverride keterlambatan karyawan.
#Konteks - Pengguna sudah melihat daftar karyawan terlambat.
#- Pengguna memilih karyawan yang keterlambatannya ingin dioverride.
#- Pengguna memilih 'override' pada 'more actions'.
#- Muncul pop up nama karyawan/nama karyawan pertama yang diceklist jika karyawan yang diceklist jumlahnya lebih dari satu, total lama keterlambatan, field dianggap terlambat berapa menit, alasan keterlambatan, dan opsi semua sama jika karyawan yang dipilih lebih dari satu.
#- Pengguna mengisi semua field yang dibutuhkan dengan data yang tidak valid.
#Ketika - Pengguna klik 'Simpan'.
#Maka - Karyawan terpilh keterlambatannya tidak jadi dioverride sesuai dengan inputan pengguna.
#- Pesan error 'Maaf ada kesalahan dalam penginputan, silahkan cek pesan di bawah' muncul.
#- Standar error pada field yang datanya tidak valid muncul.

Fitur: Daftar Karyawan Terlambat
  Untuk mengakses halaman Daftar Karyawan Terlambat
  Sebagai pengguna yang memiliki akses late_index
  Saya Ingin melihat daftar karyawan yang terlambat dihari ini atau dihari lain

Dasar: Insert data
Dengan Inisialisasi data absensi
Dan pengguna telah login

  Skenario: Pengguna membuka halaman terlambat
    Ketika pengguna berkunjung ke late page
    Maka pengguna dapat melihat 1 buah record terlambat
    Dan pengguna seharusnya melihat "Test Present Today"

  Skenario: Pengguna menggunakan filter pada halaman terlambat
    Ketika pengguna mengisikan filter tanggal
    Maka pengguna seharusnya melihat "Absent Today"
    Dan pengguna seharusnya melihat "Present Today"
