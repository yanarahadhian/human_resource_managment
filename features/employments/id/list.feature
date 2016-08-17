# language: id

Fitur: Daftar jabatan
  Sebagai superadmin
  Saya dapat melihat daftar jabatan

 Skenario: list jabatan
    Dengan saya telah login
    Ketika saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 employment berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Data Jabatan"
    Dan saya seharusnya melihat "Anggota"
    Dan saya seharusnya melihat "Accounting"