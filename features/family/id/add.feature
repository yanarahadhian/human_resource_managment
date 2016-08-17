# language: id

Fitur: Tambah keluarga
  Sebagai superadmin
  Saya dapat menambah keluarga

Skenario: list alamat
    Dengan saya telah login
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 keluarga berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Data Keluarga"
    Dan saya seharusnya melihat "Asmiranda"

 Skenario: Tambah alamat
    Dengan saya telah login
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"
    Dan saya klik "Tambah Keluarga"
    Dan saya mengisi "family_full_name" dengan "Mardhani Natsir"
    Dan saya mengisi "family_gender" dengan "Pria"
    Dan saya mengisi "family_address_attributes_street1" dengan "Jl Gurame 22 Bandung"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke person dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 2 keluarga berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Data Keluarga"
    Dan saya seharusnya melihat "Mardhani Natsir"
    Dan saya seharusnya melihat "Jl Gurame 22 Bandung"