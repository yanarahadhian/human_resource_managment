# language: id

Fitur: Tambah organisasi
  Sebagai superadmin
  Saya dapat menambah daftar organisasi

 Skenario: list organisasi
    Dengan saya telah login
    Ketika saya berkunjung ke riwayat dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 riwayat organisasi berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Lembaga bantuan hukum organisations"

 Skenario: Tambah organisasi
    Dengan saya telah login
    Dan saya berada di riwayat dengan employee_identification_number = "11"
    Dan saya klik "Tambah Organisasi"
    Dan saya mengisi "experience_start_date" dengan "1992"
    Dan saya mengisi "experience_end_date" dengan "2001"
    Dan saya mengisi "experience_company_name" dengan "Lembaga bantuan dana kemanusiaan"
    Dan saya mengisi "experience_start_date" dengan "1992"
    Dan saya mengisi "experience_end_date" dengan "2001"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke riwayat dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 2 riwayat organisasi berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Lembaga bantuan dana kemanusiaan"