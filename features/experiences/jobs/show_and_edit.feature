# language: id

Fitur: Edit pekerjaan
  Sebagai superadmin
  Saya dapat mengedit pekerjaan

Skenario: List pekerjaan
    Dengan saya telah login
    Ketika saya berkunjung ke riwayat dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 riwayat pekerjaan berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Sekretaris ,Humas"

Skenario: Show pekerjaan
    Dengan saya telah login
    Dan saya berada di riwayat dengan employee_identification_number = "11"
    Ketika saya klik "PT Sampoerna TBK"
    Maka saya seharusnya melihat "Detail Pekerjaan"
    Dan saya seharusnya melihat "Humas"
    Dan saya seharusnya melihat "Sekretaris"

Skenario: Edit pekerjaan
    Dengan saya telah login
    Dan saya berada di riwayat dengan employee_identification_number = "11"
    Ketika saya klik "PT Sampoerna TBK"
    Dan saya klik "Edit"
    Dan saya mengisi "experience_division" dengan "Marketing"
    Dan saya mengisi "experience_position_held" dengan "Follow up"
    Dan saya mengisi "experience_start_date" dengan "1992"
    Dan saya mengisi "experience_end_date" dengan "2001"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke riwayat dengan employee_identification_number = "11"
    Maka saya seharusnya melihat "Follow up ,Marketing"
    Dan saya seharusnya tidak melihat "Sekretaris ,Humas"
