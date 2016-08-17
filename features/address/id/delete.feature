# language: id

Fitur: Daftar people
  Sebagai superadmin
  Saya dapat melihat daftar people


 Skenario: list alamat
    Dengan saya telah login
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 2 alamat berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Informasi Alamat"
    Dan saya seharusnya melihat "Kompleks Puspa Regency Blok A No 1"
    Dan saya seharusnya melihat "Bandung barat"

 Skenario: list people
    Dengan saya telah login
    Dan saya berada di halaman people
    Ketika saya mencentang "myrow[ids][]" pada alamat dengan id = "1"
    Dan saya menghapus alamat
    Maka saya seharusnya memiliki 1 alamat berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya tidak melihat "Kompleks Puspa Regency Blok A No 1"