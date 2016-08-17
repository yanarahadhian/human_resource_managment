# language: id

Fitur: Edit keluarga
  Sebagai superadmin
  Saya dapat mengedit keluarga

Skenario: List keluarga
    Dengan saya telah login
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 keluarga berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Data Keluarga"
    Dan saya seharusnya melihat "Asmiranda"

Skenario: Show keluarga
    Dengan saya telah login
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"    
    Dan saya klik "Asmiranda"
    Maka saya seharusnya melihat "Edit Keluarga"
    Dan saya seharusnya melihat "Asmiranda"

Skenario: Edit keluarga
    Dengan saya telah login
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"
    Dan saya klik "Asmiranda"
    Dan saya klik "Edit"
    Dan saya mengisi "family_full_name" dengan "Anita"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke person dengan employee_identification_number = "11"
    Maka saya seharusnya melihat "Anita"
    Dan saya seharusnya tidak melihat "Asmiranda"
