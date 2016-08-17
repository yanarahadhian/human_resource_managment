# language: id

Fitur: Tambah pekerjaan
  Sebagai superadmin
  Saya dapat menambah daftar pekerjaan

 Skenario: list pekerjaan
    Dengan saya telah login
    Ketika saya berkunjung ke riwayat dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 riwayat pekerjaan berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "PT Sampoerna TBK"

 Skenario: Tambah pekerjaan
    Dengan saya telah login
    Dan saya berada di riwayat dengan employee_identification_number = "11"
    Dan saya klik "Tambah Pekerjaan"
    Dan saya mengisi "experience_start_date" dengan "1992"
    Dan saya mengisi "experience_end_date" dengan "2001"Dan saya mengisi "company_name" dengan "PT Harian baru"
    Dan saya mengisi "experience_start_date" dengan "1992"
    Dan saya mengisi "experience_end_date" dengan "2001"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke riwayat dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 2 riwayat pekerjaan berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "PT Harian baru"