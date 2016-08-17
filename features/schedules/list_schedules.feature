# language: id
# Source: http://github.com/aslakhellesoy/cucumber/blob/master/examples/i18n/en/features/addition.feature
# Updated: Tue May 25 15:51:43 +0200 2010
#
#Pengguna yang dapat mengakses halaman ini adalah pengguna dengan access key schedule_index.
#
#Pengguna dapat melihat daftar penjadwalan kerja pada suatu perusahaan sehingga memudahkan pengelolaan jadwal kerja karyawannya, terutama pada perusahaan dengan karyawan produksi yang sangat banyak/pabrik.
#
#Data yang akan ditampilkan pada daftar penjadwalan kerja adalah:
#- Periode
#- Nama shift
#- Nama Bagian
#- Jumlah Group
#- Jumlah Karyawan
#
#Pastikan bahwa data jadwal kerja yang ditampilkan sesuai dengan periode jadwal kerjanya, sehingga history jadwal kerja tetap terjaga dengan baik.
#
#Daftar dapat difilter berdasarkan kolom-kolom di atas.
#
#Skenario:
#1. Pengguna melihat daftar penjadwalan kerja yang ada pada perusahaannya.
#Konteks - Pengguna ingin melihat daftar jadwal kerja yang ada pada perusahaannya.
#Ketika - Pengguna mengakses halaman jadwal kerja.
#Maka - Jika data jadwal kerja sudah ada maka data jadwal kerja ditampilkan.
#- Jika data jadwal kerja belum ada maka pesan handle blank slate yang sesuai standar 'Data jadwal kerja belum ada' 'Silahkan 'Tambah Jadwal Kerja Baru' untuk menambah jadwal kerja baru' muncul.
#2. Pengguna melihat daftar jadwal kerja yang ada pada perusahaannya dengan filter tertentu.
#Konteks - Pengguna ingin melihat daftar jadwal kerja yang ada pada perusahaannya dengan filter.
#- Penggunsa sudah berada pada halaman daftar jadwal kerja dan melihat daftar jadwal kerja yang ada.
#- Pengguna menambahkan filter yang dibutuhkan.
#- Pengguna memberi nilai pada filter yang dipilih.
#Ketika - Pengguna klik button 'Go'
#Maka - Jika data jadwal kerja yang sesuai dengan inputan filter sudah ada maka data jadwal kerja ditampilkan.
#- Jika data jadwal kerja tidak ada yang sesuai dengan filter maka pesan handle hasil filter yang sesuai standar 'Tidak ada data jadwal kerja yang Anda cari' 'Silahkan 'Reset Filter' atau ganti parameter filter Anda' muncul.