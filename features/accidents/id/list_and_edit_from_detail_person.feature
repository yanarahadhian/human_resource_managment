# language: id

Fitur: tambah kecelakaan
  Sebagai superadmin
  Saya dapat manambah kecelakaan

 Skenario: list kecelakaan
    Dengan saya telah login
    Ketika saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya melihat "Ditabrak mobil"

 Skenario: edit pelanggaran
    Dengan saya telah login
    Ketika saya berkunjung ke edit kecelakaan dengan id =1 dan employee_identification_number = "11"
    Dan saya mengisi "accident_causes" dengan "Lagi makan kena minyak goreng panas"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke employment dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Lagi makan kena minyak goreng panas"
    Dan saya seharusnya tidak melihat "Jatuh dari motor"