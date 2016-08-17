# language: en
# Source: http://github.com/aslakhellesoy/cucumber/blob/master/examples/i18n/en/features/addition.feature
# Updated: Tue May 25 15:51:43 +0200 2010

#Pengguna yang dapat menggunakan fitur ini adalah pengguna dengan access key holiday_delete.
#
#Pengguna menghapus data libur sebagai libur perusahaan yang sudah terlanjur ditambahkan sehingga data libur yang salah dapat dihapus dan tidak mengurangi jatah cuti bersama jika cuti bersama termasuk dalam hari libur yang dihapus.
#
#1. Pengguna menghapus hari libur.
#Konteks - Pengguna mengakses halaman daftar hari libur yang ada.
#- Pengguna memilih beberapa data hari libur dan pada more actions pilih 'Delete'
#- Sistem memunculkan konfirmasi hapus.
#Ketika - Pengguna klik 'Ya' pada konfirmasi hapus
#Maka - Data terpilih berhasil terhapus.
#- Pesan sukses hapus 'Data hari libur nasional berhasil terhapus' muncul.
#2. Pengguna batal menghapus hari libur.
#Konteks - Pengguna mengakses halaman daftar hari libur yang ada.
#- Pengguna memilih beberapa data hari libur dan pada more actions pilih 'Delete'
#- Sistem memunculkan konfirmasi hapus.
#Ketika - Pengguna klik 'Tidak' pada konfirmasi hapus
#Maka - Data tidak jadi terhapus
#- Data yang awalnya terpilih jadi tidak terpilih.