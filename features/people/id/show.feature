# language: id

Fitur: Detail people
  Sebagai superadmin
  Saya dapat melihat data detail people

 Skenario: list people
    Dengan saya telah login
    Dan saya berada di halaman people
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"
    Maka saya seharusnya melihat "Nungky Selection"
    Dan saya seharusnya melihat "Informasi Pribadi"
    Dan saya seharusnya melihat "Informasi Alamat"