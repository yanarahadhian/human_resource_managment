# language: id

Fitur: Daftar keluarga
  Sebagai superadmin
  Saya dapat melihat daftar keluarga

 Skenario: list keluarga
    Dengan saya telah login
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 keluarga berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Data Keluarga"
    Dan saya seharusnya melihat "Asmiranda"