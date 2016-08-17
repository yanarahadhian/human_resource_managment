# language: id

Fitur: Daftar alamat
  Sebagai superadmin
  Saya dapat melihat daftar alamat

 Skenario: list alamat
    Dengan saya telah login
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 2 alamat berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Informasi Alamat"
    Dan saya seharusnya melihat "Kompleks Puspa Regency Blok A No 1"
    Dan saya seharusnya melihat "Bandung barat"    