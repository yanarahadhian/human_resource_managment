# language: id

Fitur: Edit pendidikan
  Sebagai superadmin
  Saya dapat mengedit pendidikan

 Skenario: list pendidikan
    Dengan saya telah login
    Ketika saya berkunjung ke riwayat dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 pendidikan berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "S1"

 Skenario: tambah pendidikan
    Dengan saya telah login
    Dan saya berada di riwayat dengan employee_identification_number = "11"
    Ketika saya klik "S1"
    Dan saya mengisi "education_pendidikan_terakhir" dengan "SLTA"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke riwayat dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "SLTA"
    Dan saya seharusnya tidak melihat "S1"