# language: id

Fitur: Edit alamat
  Sebagai superadmin
  Saya dapat mengedit alamat

Skenario: List alamat
    Dengan saya telah login
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 2 alamat berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Informasi Alamat"
    Dan saya seharusnya melihat "Kompleks Puspa Regency Blok A No 1"
    Dan saya seharusnya melihat "Bandung barat"

Skenario: Show alamat
    Dengan saya telah login
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"    
    Dan saya klik "Kompleks Puspa Regency Blok A No 1"
    Maka saya seharusnya melihat "Detail Alamat"
    Dan saya seharusnya melihat "Kompleks Puspa Regency Blok A No 1"
    Dan saya seharusnya melihat "Bandung barat"

Skenario: Edit alamat
    Dengan saya telah login
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"
    Dan saya klik "Kompleks Puspa Regency Blok A No 1"
    Dan saya klik "Edit"
    Dan saya mengisi "address_state" dengan "Aceh"
    Dan saya mengisi "address_city" dengan "Kota Sabang"
    Dan saya mengisi "address_street1" dengan "Jl Aceh utara 21"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke person dengan employee_identification_number = "11"
    Maka saya seharusnya melihat "Jl Aceh utara 21"
    Dan saya seharusnya melihat "Kota Sabang"
    Dan saya seharusnya tidak melihat "Kompleks Puspa Regency Blok A No 1"