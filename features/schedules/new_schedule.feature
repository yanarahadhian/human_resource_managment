# language: id
# Source: http://github.com/aslakhellesoy/cucumber/blob/master/examples/i18n/id/features/addition.feature
# Updated: Tue May 25 15:52:00 +0200 2010

#Pengguna yang dapat mengakses halaman ini adalah pengguna dengan access key schedule_new.
#
#Pengguna menambah jadwal kerja baru sehingga semua karyawan sudah memiliki jam kerjanya pada periode tertentu sehingga memudahkan pengguna untuk memantau absensi karyawannya nanti.
#
#Data yang dibutuhkan untuk menambah jadwal kerja baru adalah:
#1. Periode *
#2. Shift *
#3. Nama karyawan ( auto complete dengan hasil Nama karyawan - NIK - Departemen - Bagian ) *
#
#Akan ada keterangan untuk mempermudah pengguna menambah / mengedit data jadwal kerja. Keterangan untuk masing-masing field dilampirkan.
#
#Halaman ini memungkinkan pengguna assign shift pada periode tertentu kepada satu atau banyak karyawan sekaligus.
#
#Skenario:
#1. Pengguna membuat scheduling baru untuk satu atau beberapa karyawan langsung.
#   Konteks	- Pengguna ingin meng-assign karyawan pada shift tertentu.
#		- Pengguna akses halaman scheduling dan klik button 'Tambah Scheduling Baru'.
#		- Sistem menampilkan halaman tambah scheduling baru.
#		- Pengguna memilih periode dan shift apa yang akan diassign.
#		- Sistem menampilkan tabel karyawan yang ingin diassign dan ada opsi untuk assign beberapa karyawan pada bagian tertentu langsung pada sisi kanan.
#		- Pengguna mengisikan nama karyawan di tabel bagian bawah, Assign shift ke karyawan. Autocomplete nama karyawan - departemen - bagian muncul sesuai dengan nama karyawan yang diketikkan.
#		- Pengguna memilih salah satu hasil auto complete dan klik button ceklist hijau di sisi kanannya.
#		- Jika ingin menambah karyawan yang diassign lagi, pengguna dapat mengulangi step di atas dengan mengetikkan nama karyawan.
#   Ketika	- Pengguna klik button 'Simpan'
#   Maka		- Data scheduling baru tersimpan.
#		- Pengguna kembali ke halaman daftar scheduling.
#		- Pesan sukses 'Scheduling baru berhasil ditambah' muncul.
#		- Karyawan yang bersangkutan berhasil terassign pada shift tertentu selama periode tertentu.
#2. Pengguna membuat scheduling baru untuk beberapa karyawan langsung dari bagian tertentu.
#   Konteks	- Pengguna ingin meng-assign karyawan pada shift tertentu.
#		- Pengguna akses halaman scheduling dan klik button 'Tambah Scheduling Baru'.
#		- Sistem menampilkan halaman tambah scheduling baru.
#		- Pengguna memilih periode dan shift apa yang akan diassign.
#		- Sistem menampilkan tabel karyawan yang ingin diassign dan ada opsi untuk assign beberapa karyawan pada bagian tertentu langsung pada sisi kanan.
#		- Pengguna memilih nama bagian yang karyawannya ingin diassign.
#		- Sistem memunculkan daftar karyawan yang terassign pada bagian yang dipilih di bagian bawah.
#		- Jika pengguna ingin menambahkan karyawan dari group yang ada pada bagian tersebut, maka pengguna bisa memilih group pada bagian tersebut.
#		- Sistem akan menampilkan daftar karyawan yang hanya terdaftar pada group terpilih.
#		- Pengguna memilih salah satu atau beberapa nama karyawan yang ditampilkan dan klik button ceklist hijau di sisi kanannya.
#		- Karyawan terpilih namanya akan berpindah ke daftar karyawan yang diassign ke shift di sisi kiri.
#		- Jika ingin menambah karyawan dari bagian lain, maka pengguna dapat mengulangi step di atas.
#   Ketika	- Pengguna klik button 'Simpan'
#   Maka		- Data scheduling baru tersimpan.
#		- Pengguna kembali ke halaman daftar scheduling.
#		- Pesan sukses 'Scheduling baru berhasil ditambah' muncul.
#		- Karyawan dari bagian yang bersangkutan berhasil terassign pada shift tertentu selama periode tertentu.
#3. Pengguna membuat scheduling baru untuk karyawan langsung dan karyawan dari bagian tertentu.
#   Konteks	- Pengguna ingin meng-assign karyawan pada shift tertentu.
#		- Pengguna akses halaman scheduling dan klik button 'Tambah Scheduling Baru'.
#		- Sistem menampilkan halaman tambah scheduling baru.
#		- Pengguna memilih periode dan shift apa yang akan diassign.
#		- Sistem menampilkan tabel karyawan yang ingin diassign dan ada opsi untuk assign beberapa karyawan pada bagian tertentu langsung pada sisi kanan.
#		  Pengguna assign beberapa karyawan langsung:
#		- Pengguna mengisikan nama karyawan di tabel bagian bawah, Assign shift ke karyawan. Autocomplete nama karyawan - departemen - bagian muncul sesuai dengan nama karyawan yang diketikkan.
#		- Pengguna memilih salah satu hasil auto complete dan klik button ceklist hijau di sisi kanannya.
#		- Jika ingin menambah karyawan yang diassign lagi, pengguna dapat mengulangi step di atas dengan mengetikkan nama karyawan.
#		  Pengguna assign karyawan dari bagian:
#		- Pengguna memilih nama bagian yang karyawannya ingin diassign.
#		- Sistem memunculkan daftar karyawan yang terassign pada bagian yang dipilih di bagian bawah.
#		- Jika pengguna ingin menambahkan karyawan dari group yang ada pada bagian tersebut, maka pengguna bisa memilih group pada bagian tersebut.
#		- Sistem akan menampilkan daftar karyawan yang hanya terdaftar pada group terpilih.
#		- Pengguna memilih salah satu atau beberapa nama karyawan yang ditampilkan dan klik button ceklist hijau di sisi kanannya.
#		- Karyawan terpilih namanya akan berpindah ke daftar karyawan yang diassign ke shift di sisi kiri.
#		- Jika ingin menambah karyawan dari bagian lain, maka pengguna dapat mengulangi step di atas.
#   Ketika	- Pengguna klik button 'Simpan'
#   Maka		- Data scheduling baru tersimpan.
#		- Pengguna kembali ke halaman daftar scheduling.
#		- Pesan sukses 'Scheduling baru berhasil ditambah' muncul.
#		- Karyawan dari bagian yang bersangkutan berhasil terassign pada shift tertentu selama periode tertentu.
#4. Pengguna membuat scheduling baru untuk karyawan yang sudah terassign pada shift lain di periode tertentu.
#   Konteks	- Pengguna ingin meng-assign karyawan pada shift tertentu.
#		- Pengguna akses halaman scheduling dan klik button 'Tambah Scheduling Baru'.
#		- Sistem menampilkan halaman tambah scheduling baru.
#		- Pengguna memilih periode dan shift apa yang akan diassign.
#		- Sistem menampilkan tabel karyawan yang ingin diassign dan ada opsi untuk assign beberapa karyawan pada bagian tertentu langsung pada sisi kanan.
#		- Pengguna mengisikan nama karyawan di tabel bagian bawah, Assign shift ke karyawan. Autocomplete nama karyawan - departemen - bagian muncul sesuai dengan nama karyawan yang diketikkan.
#		- Pengguna memilih salah satu hasil auto complete dan klik button ceklist hijau di sisi kanannya.
#		- Ternyata karyawan terpilih sudah terassign pada shift lain di periode yang sama, sehingga sistem memunculkan konfirmasi 'Karyawan telah diassign pada shift lain di periode ini. Apakah Anda yakin ingin memindahkan shift karyawan?'
#		- Jika pengguna ingin memindahkan shift karyawan maka pengguna bisa klik ya.
#		- Jika pengguna tidak ingin memindahkan shift karyawan maka pengguna bisa klik tidak.
#		- Jika ingin menambah karyawan yang diassign lagi, pengguna dapat mengulangi step di atas dengan mengetikkan nama karyawan.
#   Ketika	- Pengguna klik button 'Simpan'
#   Maka		- Data scheduling baru tersimpan.
#		- Pengguna kembali ke halaman daftar scheduling.
#		- Pesan sukses 'Scheduling baru berhasil ditambah' muncul.
#		- Karyawan yang bersangkutan berhasil terassign pada shift tertentu selama periode tertentu.

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
