# language: id
# Source: http://github.com/aslakhellesoy/cucumber/blob/master/examples/i18n/id/features/addition.feature
# Updated: Tue May 25 15:52:00 +0200 2010
#Pengguna yang dapat mengakses halaman ini adalah pengguna dengan access key present_detail.
#
#Pengguna melihat detail absensi karyawan sehingga summary absensi karyawan tersebut dapat dilihat dengan mudah.
#
#Halaman ini dapat diakses dengan klik 'nama karyawan' yang ada pada halaman absensi kerja.
#
#Akan ada 3 jenis detail absensi yang dimunculkan, yaitu:
#1. Tab Harian
#Tab ini digunakan untuk menampilkan daftar absensi harian karyawan, dapat ditampilkan dengan filter tanggal.
#2. Tab Bulanan
#Tab ini digunakan untuk menampilkan daftar absensi bulanan karyawan, dapat ditampilkan dengan filter periode (bulan dan tahun). Kolom yang ditampilkan adalah Hari | Tanggal | Lama Kerja | Lama Istirahat | Keterangan.
#3. Tab Tahunan
#Tab ini digunakan untuk menampilkan daftar absensi tahunan karyawan.
#Dimunculkan dalam bentuk bagian-bagian, yaitu jumlah hari karyawan masuk, jumlah hari karyawan cuti, jumlah hari karyawan sakit, jumlah hari karyawan ijin, dan jumlah hari lain-lain karyawan tidak masuk. Untuk masing-masing bagiannya dapat diklik untuk dimunculkan detail keterangan nya sehingga pengguna tahu kapan karyawan masuk dan kapan karyawan tidak masuk.

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
