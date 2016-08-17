# language: id

Fitur: hapus kecelakaan
  Sebagai superadmin
  Saya dapat menghapus kecelakaan

 Skenario: list kecelakaan
    Dengan saya telah login
    Ketika saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 kecelakaan berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Ditabrak mobil"

 Skenario: tambah pelanggaran
    Dengan saya telah login
    Dan saya berada di employment dengan employee_identification_number = "11"
    Ketika saya mencentang "myrow[ids][]" pada kecelakaan dengan id = "1"
    Dan saya menghapus kecelakaan
    Maka saya seharusnya memiliki 0 kecelakaan berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya tidak melihat "Ditabrak mobil"