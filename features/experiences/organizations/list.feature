# language: id

Fitur: Daftar pekerjaan
  Sebagai superadmin
  Saya dapat melihat daftar pekerjaan

 Skenario: list keluarga
    Dengan saya telah login
    Ketika saya berkunjung ke riwayat dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 riwayat organisasi berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Lembaga bantuan hukum organisations"