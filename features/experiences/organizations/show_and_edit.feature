# language: id

Fitur: Edit organisasi
  Sebagai superadmin
  Saya dapat mengedit organisasi

Skenario: List organisasi
    Dengan saya telah login
    Ketika saya berkunjung ke riwayat dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 riwayat organisasi berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Sekretaris ,Humas"

Skenario: Show organisasi
    Dengan saya telah login
    Dan saya berada di riwayat dengan employee_identification_number = "11"
    Ketika saya klik "Lembaga bantuan hukum organisations"
    Maka saya seharusnya melihat "Detail Organisasi"
    Dan saya seharusnya melihat "Lembaga bantuan hukum organisations "

Skenario: Edit organisasi
    Dengan saya telah login
    Dan saya berada di riwayat dengan employee_identification_number = "11"
    Ketika saya klik "Lembaga bantuan hukum organisations"
    Dan saya klik "Edit"
    Dan saya mengisi "experience_company_name" dengan "Lembaga bantuan bencana alam"
    Dan saya mengisi "experience_start_date" dengan "1992"
    Dan saya mengisi "experience_end_date" dengan "2001"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke riwayat dengan employee_identification_number = "11"
    Maka saya seharusnya melihat "Lembaga bantuan bencana alam"
    Dan saya seharusnya tidak melihat "Lembaga bantuan hukum organisations"