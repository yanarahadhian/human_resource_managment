# language: id

Fitur: Daftar pelatihan
  Sebagai superadmin
  Saya dapat melihat daftar pelatihan

 Skenario: list pelatihan
    Dengan saya telah login
    Ketika saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 3 pelatihan berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Data Pelatihan"
    Dan saya seharusnya melihat "Jack fernandes"