# language: id

Fitur: Tambah alamat
  Sebagai superadmin
  Saya dapat menambah alamat

Skenario: list alamat
    Dengan saya telah login
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 2 alamat berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Informasi Alamat"
    Dan saya seharusnya melihat "Kompleks Puspa Regency Blok A No 1"
    Dan saya seharusnya melihat "Bandung barat"

 Skenario: Tambah alamat
    Dengan saya telah login
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"
    Dan saya klik "Tambah Alamat"
    Dan saya mengisi "address_state" dengan "Jawa Barat"
    Dan saya mengisi "address_city" dengan "Kota Bandung"
    Dan saya mengisi "address_street1" dengan "Jl Ahmad yani 21 Bandung"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke person dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 3 alamat berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Jl Ahmad yani 21 Bandung"
    Dan saya seharusnya melihat "Jawa Barat"
    Dan saya seharusnya melihat "Kota Bandung"