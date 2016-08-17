# language: id

Fitur: tambah kecelakaan
  Sebagai superadmin
  Saya dapat manambah kecelakaan

 Skenario: list kecelakaan
    Dengan saya telah login
    Ketika saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 kecelakaan berdasarkan person dengan employee_identification_number = "11"

 Skenario: tambah pelanggaran
    Dengan saya telah login
    Ketika saya berkunjung ke tambah kecelakaan dengan employee_identification_number = "11"
    Dan saya mengisi "accident_accident_date" dengan "15/01/2012"
    Dan saya mengisi "autocomplete_accident_location_name" dengan "Depan gedung sate bandung"
    Dan saya mengisi "accident_accident_person_in_charge" dengan "Dani Ramadhani"
    Dan saya mengisi "accident_causes" dengan "Jatuh dari motor"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 2 kecelakaan berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Jatuh dari motor"