# language: id

Fitur: Daftar pendidikan
  Sebagai superadmin
  Saya dapat melihat daftar pendidikan

 Skenario: list pendidikan
    Dengan saya telah login
    Ketika saya berkunjung ke riwayat dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 pendidikan berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "S1"
    Dan saya seharusnya melihat "7.7"