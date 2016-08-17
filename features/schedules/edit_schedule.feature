# language: id
# Source: http://github.com/aslakhellesoy/cucumber/blob/master/examples/i18n/id/features/addition.feature
# Updated: Tue May 25 15:52:00 +0200 2010

#Pengguna yang dapat mengakses halaman ini adalah pengguna dengan access key schedule_edit.
#
#Pengguna mengedit penjadwalan kerja yang ada untuk merubah data yang salah dimasukkan sehingga pengguna tidak perlu repot membuat penjadwalan kerja baru.
#
#Skenario:
#1. Pengguna mengedit penjadwalan kerja yang sudah ada.
#Konteks - Pengguna ingin mengedit data penjadwalan kerja yang ada karena salah input data.
#- Pengguna akses halaman daftar penjadwalan kerja.
#- Pengguna memilih nama shift pada periode yang ingin diedit.
#- Pengguna masuk ke halaman edit jadwal kerja dengan data yang ada terpopulate pada field nya masing-masing.
#- Pengguna mengedit data yang dibutuhkan untuk diedit dengan data yang valid.
#Ketika - Pengguna klik button 'Simpan'
#Maka - Data penjadwalan kerja berhasil teredit.
#- Pengguna kembali ke halaman daftar penjadwalan kerja.
#- Pesan sukses 'Penjadwalan kerja berhasil diedit' muncul.
#- Karyawan yang bersangkutan berhasil terassign pada shift tertentu selama periode tertentu.
#2. Pengguna mengedit penjadwalan kerja yang sudah ada dengan data yang tidak valid.
#Konteks - Pengguna ingin mengedit data penjadwalan kerja yang ada karena salah input data.
#- Pengguna akses halaman daftar penjadwalan kerja.
#- Pengguna memilih nama shift pada periode yang ingin diedit.
#- Pengguna masuk ke halaman edit jadwal kerja dengan data yang ada terpopulate pada field nya masing-masing.
#- Pengguna mengedit data yang dibutuhkan untuk diedit dengan data yang tidak valid.
#Ketika - Pengguna klik button 'Simpan'
#Maka - Data penjadwalan kerja tidak berhasil teredit.
#- Pengguna tetap berada pada halaman edit jadwal kerja.
#- Pesan notifikasi 'Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali' muncul.
#- Pesan error muncul pada tiap field yang nilainya tidak valid.
#- Karyawan dari bagian yang bersangkutan belum berhasil terassign pada shift tertentu selama periode tertentu.
#3. Pengguna mengedit jadwal kerja untuk karyawan yang sudah terassign pada shift lain di periode tertentu.
#Konteks - Pengguna berada pada halaman edit.
#- Pengguna assign karyawan yang sudah terassign pada shift lain di periode yang sama.
#- Sistem memunculkan konfirmasi 'Karyawan telah diassign pada shift lain di periode ini. Apakah Anda yakin ingin memindahkan shift karyawan?'
#- Jika pengguna ingin memindahkan shift karyawan maka pengguna bisa klik ya.
#- Jika pengguna tidak ingin memindahkan shift karyawan maka pengguna bisa klik tidak.
#- Jika ingin menambah karyawan yang diassign lagi, pengguna dapat mengulangi step di atas dengan mengetikkan nama karyawan.
#Ketika - Pengguna klik button 'Simpan'
#Maka - Data scheduling teredit.
#- Pengguna kembali ke halaman daftar jadwal kerja.
#- Pesan sukses 'Jadwal kerja berhasil diedit' muncul.
#- Karyawan yang bersangkutan berhasil terassign pada shift tertentu selama periode tertentu.

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
