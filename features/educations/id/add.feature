# language: id

Fitur: Tambah pendidikan
  Sebagai superadmin
  Saya dapat menambah pendidikan

 Skenario: list pendidikan
    Dengan saya telah login
    Ketika saya berkunjung ke riwayat dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 pendidikan berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya tidak melihat "S2"

 Skenario: tambah pendidikan
    Dengan saya telah login
    Dan saya berada di riwayat dengan employee_identification_number = "11"
    Ketika saya klik "Tambah Pendidikan"
    Dan saya mengisi "education_pendidikan_terakhir" dengan "S2"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke riwayat dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 2 pendidikan berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "S2"