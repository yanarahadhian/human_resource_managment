# language: id

Fitur: tambah kecelakaan
  Sebagai superadmin
  Saya dapat manambah kecelakaan

 Skenario: list kecelakaan
    Dengan saya telah login
    Ketika saya berkunjung ke kecelakaan kerja
    Maka saya seharusnya melihat "Ditabrak mobil"

 Skenario: edit pelanggaran
    Dengan saya telah login
    Ketika saya berkunjung ke edit kecelakaan kerja dengan id =1 
    Dan saya mengisi "accident_causes" dengan "Lagi makan kena minyak goreng panas"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke kecelakaan kerja
    Dan saya seharusnya melihat "Lagi makan kena minyak goreng panas"
    Dan saya seharusnya tidak melihat "Jatuh dari motor"