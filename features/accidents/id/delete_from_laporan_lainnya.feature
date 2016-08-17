# language: id

Fitur: hapus kecelakaan kerja
  Sebagai superadmin
  Saya dapat menghapus kecelakaan kerja

 Skenario: list kecelakaan kerja
    Dengan saya telah login
    Ketika saya berkunjung ke kecelakaan kerja
    Maka saya seharusnya memiliki 1 kecelakaan kerja
    Dan saya seharusnya melihat "Ditabrak mobil"

 Skenario: hapus kecelakaan kerja
    Dengan saya telah login
    Dan saya berada di kecelakaan kerja
    Ketika saya mencentang "myrow[ids][]" pada kecelakaan kerja dengan id = "1"
    Dan saya menghapus kecelakaan kerja
    Maka saya seharusnya memiliki 0 kecelakaan kerja
    Dan saya seharusnya tidak melihat "Ditabrak mobil"